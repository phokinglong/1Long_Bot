import os
import logging
import openai
from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from dotenv import load_dotenv

from fastapi.responses import JSONResponse
from config.database import get_db
from app.models.research import ResearchQuery
from app.schemas.research_schema import ResearchRequest, ResearchResponse

load_dotenv()
logging.basicConfig(level=logging.INFO)

openai.api_key = os.getenv("OPENAI_API_KEY")
if not openai.api_key:
    raise RuntimeError("OPENAI_API_KEY is missing! Set it in your environment.")

router = APIRouter()

# For now, let's only reference one website as requested
FINANCE_SITE = "https://vietstock.vn/"


@router.post("/research", response_model=ResearchResponse)
async def create_research_query(
    request: ResearchRequest,
    db: Session = Depends(get_db)
) -> JSONResponse:
    """
    POST /api/research
    Expects JSON like:
    {
      "stock_symbol": "VCB",
      "metrics": [
        {"metric_name": "income_statement"},
        {"metric_name": "cash_flow"}
      ]
    }
    Returns AI-based short summary and tabular data for each metric by year.
    """

    stock = request.stock_symbol.strip().upper()
    if not stock:
        raise HTTPException(status_code=400, detail="Stock symbol cannot be empty.")

    # Convert user’s list of metrics to a comma-separated string
    selected_metrics_list = [m.metric_name for m in request.metrics]
    if not selected_metrics_list:
        raise HTTPException(status_code=400, detail="No metrics selected.")

    joined_metrics = ", ".join(selected_metrics_list)
    
    # Prompt in Vietnamese, instruct GPT to output tables for each metric
    user_message = (
        f"Tôi muốn nghiên cứu cổ phiếu {stock} trên thị trường chứng khoán Việt Nam. "
        f"Các chỉ số tôi quan tâm: {joined_metrics}. "
        f"Giả định tôi đang xem dữ liệu từ trang {FINANCE_SITE}.\n\n"
        "Vui lòng trình bày kết quả cho mỗi chỉ số ở dạng bảng (theo từng năm gần đây). "
        "Mỗi bảng nên có các cột tương ứng với chỉ số đó (ví dụ: Doanh thu, Lợi nhuận, Dòng tiền v.v.) "
        "và các hàng là các năm khác nhau. Sau bảng, đưa ra phân tích tóm tắt 100% bằng tiếng Việt."
    )

    # Save a DB record first (with no result yet)
    research_record = ResearchQuery(
        stock_symbol=stock,
        selected_metrics=joined_metrics,
        result=""  # Will fill in after GPT returns
    )
    db.add(research_record)
    db.commit()
    db.refresh(research_record)

    try:
        # Example usage for openai>=1.0.0
        response = openai.chat.completions.create(
            model="gpt-4-turbo",  # or "gpt-3.5-turbo"
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Bạn là 'Cộng sự Nghiên cứu', một AI chuyên phân tích cổ phiếu VN. "
                        "Sử dụng dữ liệu (giả lập) từ Vietstock.vn để đưa ra bảng số liệu và phân tích. "
                        "Chỉ viết bằng tiếng Việt."
                    )
                },
                {"role": "user", "content": user_message},
            ],
            max_tokens=1200,
            temperature=0.7
        )

        # Extract GPT’s text
        raw_reply = response.choices[0].message.content.strip()
        ai_reply = raw_reply.encode("utf-8", "replace").decode("utf-8", "replace")

        # Update DB record with the result
        research_record.result = ai_reply
        db.commit()

        # Construct a Pydantic response
        result_data = {
            "stock_symbol": stock,
            "metrics": selected_metrics_list,
            "analysis": ai_reply
        }
        return JSONResponse(content=result_data, media_type="application/json; charset=utf-8")

    except Exception as e:
        logging.exception("OpenAI error in advanced research plan")
        raise HTTPException(
            status_code=500,
            detail="Không thể thực hiện phân tích cổ phiếu lúc này."
        ) from e
