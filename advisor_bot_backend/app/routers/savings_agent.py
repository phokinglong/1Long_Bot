# app/routers/savings_agent.py

import os
import logging
import math
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
import openai
from dotenv import load_dotenv

from fastapi.responses import JSONResponse
from app.database import get_db
from app.models.savings import SavingsPlan

load_dotenv()
logging.basicConfig(level=logging.INFO)
openai.api_key = os.getenv("OPENAI_API_KEY")

router = APIRouter()

class SavingsRequest(BaseModel):
    goal_name: str
    goal_amount: float
    months: int
    desired_return_rate: float  # e.g. 0.05 for 5%, 0.2 for 20%

@router.post("/savings")
async def create_advanced_savings_plan(
    request: SavingsRequest, 
    db: Session = Depends(get_db)
) -> JSONResponse:
    """
    Tạo kế hoạch tiết kiệm + danh mục đầu tư (VNĐ), 
    đồng thời lưu DB, trả về phản hồi AI/Month-by-month.
    """

    if request.goal_amount <= 0 or request.months <= 0:
        raise HTTPException(
            status_code=400,
            detail="Số tiền mục tiêu (goal_amount) và số tháng (months) phải > 0."
        )

    if not (0.0 <= request.desired_return_rate <= 0.3):
        # Arbitrary limit: 0-30% annual
        raise HTTPException(
            status_code=400,
            detail="desired_return_rate phải trong khoảng 0 -> 0.3 (0% -> 30%)."
        )

    # 1. Tính monthly savings (naive approach, ignoring investment growth).
    #    If we incorporate the desired return, we can reduce the monthly deposit.
    #    Simple formula if we want the FUTURE VALUE of an annuity with monthly rate = (1 + annual_rate)^(1/12)-1
    monthly_rate = (1 + request.desired_return_rate)**(1/12) - 1  # approximate
    # sum_{k=0 to n-1} deposit * (1+monthly_rate)^(n-1-k) = goal_amount
    # => deposit * [((1+monthly_rate)^n - 1) / monthly_rate] = goal_amount
    # => deposit = goal_amount * monthly_rate / ((1+monthly_rate)^n - 1)
    # but handle monthly_rate=0 edge case
    n = request.months
    if monthly_rate > 0:
        deposit = (
            request.goal_amount * monthly_rate /
            ((1 + monthly_rate)**n - 1)
        )
    else:
        # if desired_return_rate=0 => just goal_amount / months
        deposit = request.goal_amount / request.months

    # 2. portfolio allocation strategy. 
    #    We'll do a naive approach:
    #    if desired_return_rate < 0.08 => mostly term deposit
    #    if 0.08 < rate < 0.15 => split 
    #    else => mostly stocks
    if request.desired_return_rate <= 0.05:
        allocation = "100% Gửi tiết kiệm kỳ hạn (5%/năm)."
    elif request.desired_return_rate <= 0.12:
        allocation = "50% Gửi tiết kiệm, 50% Cổ phiếu."
    else:
        allocation = "75% Cổ phiếu, 25% Gửi tiết kiệm."

    # 3. Gọi OpenAI => AI gợi ý chi tiết, month-by-month breakdown, motivational tips
    user_prompt = f"""
Bạn là một cố vấn tiết kiệm. Tôi muốn tiết kiệm cho mục tiêu: {request.goal_name}.
Số tiền mục tiêu: {request.goal_amount} VNĐ.
Thời gian: {request.months} tháng.
Lãi suất mong muốn: {request.desired_return_rate*100:.1f} % / năm.

Tính giúp tôi số tiền tiết kiệm mỗi tháng, 
kèm theo gợi ý phân bổ danh mục ({allocation}) 
và 1-2 lời khuyên khích lệ. 
Trả lời bằng tiếng Việt, không dùng LaTeX.
"""
    try:
        ai_response = openai.chat.completions.create(
            model="gpt-4",  # or "gpt-3.5-turbo"
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Bạn là một cố vấn tài chính thân thiện, "
                        "luôn trả lời hoàn toàn bằng tiếng Việt."
                    )
                },
                {"role": "user", "content": user_prompt}
            ],
            max_tokens=700,
            temperature=0.7
        )
        raw_ai = ai_response.choices[0].message.content.strip()
        ai_advice = raw_ai.encode("utf-8", "replace").decode("utf-8", "replace")

    except Exception as exc:
        logging.exception("OpenAI error in advanced savings plan")
        ai_advice = "Không thể lấy gợi ý AI lúc này."

    # 4. Lưu DB
    saving_plan = SavingsPlan(
        goal_name=request.goal_name,
        goal_amount=request.goal_amount,
        months=request.months,
        monthly_savings=deposit,
        motivational_tips=ai_advice,
        desired_return_rate=request.desired_return_rate
    )
    db.add(saving_plan)
    db.commit()
    db.refresh(saving_plan)

    # 5. Build response
    result = {
        "goal_name": saving_plan.goal_name,
        "goal_amount": saving_plan.goal_amount,
        "months": saving_plan.months,
        "monthly_savings": round(saving_plan.monthly_savings),
        "portfolio_allocation": allocation,
        "ai_advice": saving_plan.motivational_tips
    }
    return JSONResponse(content=result, media_type="application/json; charset=utf-8")
