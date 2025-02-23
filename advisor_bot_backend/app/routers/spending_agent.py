# advisor_bot_backend/app/routers/spending_agent.py

import os
import logging
import openai

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from config.database import get_db
from app.models.spending import Income, Expense
from app.schemas.spending_schema import SpendingRequest

router = APIRouter()
logging.basicConfig(level=logging.INFO)

# Example set of suggested prompts
SUGGESTED_PROMPTS = {
    "budgeting": "What's the best way to allocate my income for savings and spending?",
    "cost_saving": "How can I reduce my monthly expenses while maintaining my lifestyle?",
    "debt_management": "How should I prioritize paying off my debts while still saving money?",
    "investment_tips": "Based on my spending, what percentage of my income should go into investments?",
}

@router.post("/spending")
def create_spending_plan(request: SpendingRequest, db: Session = Depends(get_db)):
    """
    POST /api/spending
    Expects JSON:
    {
        "monthly_income": 5000,
        "expenses": [
            {"category": "Rent", "amount": 1200},
            {"category": "Groceries", "amount": 400},
            ...
        ]
    }
    Returns: {
      "plan": "...AI-generated budget plan...",
      "suggested_prompts": [...]
    }
    """

    # 1. Check OpenAI key
    openai_api_key = os.getenv("OPENAI_API_KEY")
    if not openai_api_key:
        logging.error("OpenAI API key is not set. Please check your environment variables.")
        raise HTTPException(
            status_code=500,
            detail="OpenAI API key is missing or invalid. Please contact support."
        )

    openai.api_key = openai_api_key

    # 2. Save the Spending record
    income_record = Income(monthly_income=request.monthly_income)
    db.add(income_record)
    db.commit()
    db.refresh(income_record)

    # 3. Save each Expense
    for expense_item in request.expenses:
        expense_record = Expense(
            category=expense_item.category,
            amount=expense_item.amount,
            income_id=income_record.id
        )
        db.add(expense_record)
    db.commit()

    # 4. Build the user message for OpenAI
    user_expenses_str = "\n".join([f"- {e.category}: ${e.amount}" for e in request.expenses])
    user_message = (
        f"My monthly income is ${request.monthly_income}, and here’s my expense breakdown:\n"
        f"{user_expenses_str}\n\n"
        "Based on this data, suggest a better spending strategy. Identify areas to cut back "
        "and improve savings. Provide 2-3 actionable tips to optimize my budget."
    )

    # 5. Call OpenAI
    try:

        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",  # or "gpt-4" if you have access
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are 'Cộng sự Chi tiêu', a personal finance assistant. "
                        "Help users create a smarter budget by analyzing their income and spending. "
                        "Suggest improvements, highlight potential savings, and provide cost-saving ideas."
                    )
                },
                {"role": "user", "content": user_message}
            ],
            max_tokens=500,
            temperature=0.7
        )

        ai_reply = response.choices[0].message.content

        return {
            "plan": ai_reply,
            "suggested_prompts": list(SUGGESTED_PROMPTS.values())
        }

    except Exception as e:
        logging.exception("OpenAI error occurred in create_spending_plan")
        raise HTTPException(
            status_code=500,
            detail="An error occurred while generating your spending plan."
        ) from e
