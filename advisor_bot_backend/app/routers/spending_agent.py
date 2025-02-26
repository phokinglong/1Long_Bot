import os
import logging
import openai
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from dotenv import load_dotenv

from fastapi.responses import JSONResponse  # <-- We return JSONResponse
from config.database import get_db
from app.models.spending import Income, Expense
from app.schemas.spending_schema import SpendingRequest

load_dotenv()
logging.basicConfig(level=logging.INFO)
openai.api_key = os.getenv("OPENAI_API_KEY")

router = APIRouter()

# Ví dụ về các gợi ý tiếp theo (trả về cho FE hiển thị, đã chuyển sang tiếng Việt)
SUGGESTED_PROMPTS = {
    "budgeting": "Làm thế nào để phân bổ thu nhập cho tiết kiệm và chi tiêu?",
    "cost_saving": "Làm sao giảm chi phí hàng tháng mà vẫn giữ phong cách sống?",
    "debt_management": "Nên ưu tiên trả nợ như thế nào trong khi vẫn tiết kiệm?",
    "investment_tips": "Dựa trên chi tiêu, tôi nên đầu tư bao nhiêu phần trăm thu nhập?",
}

@router.post("/spending")
def create_spending_plan(
    request: SpendingRequest,
    db: Session = Depends(get_db)
) -> JSONResponse:
    """
    POST /api/spending
    Dữ liệu JSON cần:
    {
      "monthly_income": 5000,
      "expenses": [
        {"category": "Thuê nhà", "amount": 1200},
        {"category": "Đi chợ", "amount": 400},
        ...
      ]
    }
    Trả về:
    {
      "plan": "...Kế hoạch chi tiêu từ AI (tiếng Việt)...",
      "suggested_prompts": [...]
    }
    """

    # 1. Kiểm tra API key của OpenAI
    openai_api_key = os.getenv("OPENAI_API_KEY")
    if not openai_api_key:
        logging.error("Chưa thiết lập OpenAI API key. Vui lòng kiểm tra biến môi trường.")
        raise HTTPException(
            status_code=500,
            detail="Chưa có OpenAI API key hoặc không hợp lệ. Liên hệ hỗ trợ."
        )

    openai.api_key = openai_api_key

    # 2. Lưu bản ghi Income (thu nhập)
    income_record = Income(monthly_income=request.monthly_income,user_id=request.user_id)
    db.add(income_record)
    db.commit()
    db.refresh(income_record)

    # 3. Lưu các khoản Expense (chi tiêu)
    for expense_item in request.expenses:
        expense_record = Expense(
            category=expense_item.category,
            amount=expense_item.amount,
            income_id=income_record.id
        )
        db.add(expense_record)
    db.commit()

    # 4. Xây dựng nội dung tin nhắn gửi OpenAI (tiếng Việt)
    user_expenses_str = "\n".join([
        f"- {e.category}: {e.amount} VNĐ" for e in request.expenses
    ])
    user_message = (
        f"Thu nhập hàng tháng của tôi là {request.monthly_income} VNĐ. "
        f"Dưới đây là chi tiết các khoản chi tiêu:\n{user_expenses_str}\n\n"
        "Dựa trên thông tin này, hãy đề xuất một kế hoạch chi tiêu hợp lý, "
        "chỉ ra các khoản có thể cắt giảm và tối ưu hóa ngân sách. "
        "Vui lòng trả lời hoàn toàn bằng tiếng Việt, kèm theo 2-3 gợi ý cụ thể."
    )

    # 5. Gọi OpenAI (ChatCompletion) để lấy phản hồi (UTF-8 an toàn)
    try:
        response = openai.chat.completions.create(
            model="gpt-4-turbo",  # hoặc "gpt-4" nếu có quyền truy cập
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Bạn là 'Cộng sự Chi tiêu', một trợ lý tài chính cá nhân. "
                        "Luôn trả lời 100% bằng tiếng Việt, không dùng tiếng Anh."
                    )
                },
                {"role": "user", "content": user_message}
            ],
            max_tokens=1000,
            temperature=0.7
        )

        # Encode+decode để đảm bảo UTF-8 hợp lệ
        raw_reply = response.choices[0].message.content.strip()
        ai_reply = raw_reply.encode("utf-8", "replace").decode("utf-8", "replace")

        # 6. Trả về JSONResponse (UTF-8)
        return JSONResponse(
            content={
                "plan": ai_reply,
                "suggested_prompts": list(SUGGESTED_PROMPTS.values())
            },
            media_type="application/json; charset=utf-8"
        )

    except Exception as e:
        logging.exception("Đã xảy ra lỗi khi gọi OpenAI trong create_spending_plan")
        raise HTTPException(
            status_code=500,
            detail="Có lỗi xảy ra khi tạo kế hoạch chi tiêu từ AI."
        ) from e
