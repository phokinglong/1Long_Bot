import os
import logging
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
import openai
from dotenv import load_dotenv

from fastapi.responses import JSONResponse
from app.database import get_db
from app.models.savings import SavingsPlan

# Load environment variables
load_dotenv()

logging.basicConfig(level=logging.INFO)
openai.api_key = os.getenv("OPENAI_API_KEY")

router = APIRouter()

class SavingsRequest(BaseModel):
    goal_amount: float
    months: int

@router.post("/savings")
async def create_savings_plan(request: SavingsRequest, db: Session = Depends(get_db)) -> JSONResponse:
    """
    Tạo kế hoạch tiết kiệm, lưu DB, trả về phản hồi AI (KHÔNG dùng LaTeX).
    """
    if request.goal_amount <= 0 or request.months <= 0:
        raise HTTPException(
            status_code=400,
            detail="Số tiền mục tiêu và số tháng phải lớn hơn 0."
        )

    monthly_savings = request.goal_amount / request.months

    # --- Prompt in Vietnamese, explicitly disallowing LaTeX or math formatting ---
    user_message = (
        f"Tôi muốn tiết kiệm {request.goal_amount} VNĐ trong {request.months} tháng. "
        f"Mỗi tháng tôi nên để dành bao nhiêu? Vui lòng đưa ra 1-2 lời khuyên khích lệ. "
        "Tuyệt đối KHÔNG sử dụng LaTeX hay ký hiệu toán học; hãy trả lời bằng văn bản thuần."
    )

    try:
        response = openai.chat.completion.create(
            model="gpt-4-turbo",  # or "gpt-4" if you have access
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Bạn là một cố vấn tiết kiệm thân thiện, trả lời hoàn toàn bằng tiếng Việt. "
                        "KHÔNG dùng LaTeX, ký hiệu toán học, hay bất kỳ công thức. "
                        "Chỉ dùng văn bản thuần để giải thích."
                    )
                },
                {"role": "user", "content": user_message}
            ],
            max_tokens=600,
            temperature=0.7
        )

        # Extract the raw AI reply, then encode/decode to ensure valid UTF-8
        raw_reply = response.choices[0].message.content.strip()
        motivational_tips = raw_reply.encode("utf-8", "replace").decode("utf-8", "replace")

        # Lưu SavingsPlan vào DB
        savings_plan = SavingsPlan(
            goal_amount=request.goal_amount,
            months=request.months,
            monthly_savings=monthly_savings,
            motivational_tips=motivational_tips
        )
        db.add(savings_plan)
        db.commit()
        db.refresh(savings_plan)

        # Build the response data
        result = {
            "goal_amount": savings_plan.goal_amount,
            "months": savings_plan.months,
            "monthly_savings": round(savings_plan.goal_amount / savings_plan.months, 2),
            "motivational_tips": savings_plan.motivational_tips
        }

        # Return as JSON with UTF-8
        return JSONResponse(
            content=result,
            media_type="application/json; charset=utf-8"
        )

    except Exception as e:
        logging.exception("Lỗi khi gọi OpenAI trong create_savings_plan")
        raise HTTPException(
            status_code=500,
            detail="Gặp lỗi khi tạo kế hoạch tiết kiệm từ AI."
        ) from e
