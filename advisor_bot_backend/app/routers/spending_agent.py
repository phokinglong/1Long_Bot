import os
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field, validator
from typing import List
from dotenv import load_dotenv
import openai

load_dotenv()
logging.basicConfig(level=logging.INFO)

openai.api_key = os.getenv("OPENAI_API_KEY")

router = APIRouter()

# Expense input model with validation to ensure positive amounts.
class ExpenseItem(BaseModel):
    category: str
    amount: float = Field(..., gt=0, description="Expense amount must be positive")

# Spending request model with a validator to ensure at least one expense is provided.
class SpendingRequest(BaseModel):
    monthly_income: float = Field(..., gt=0, description="Monthly income must be positive")
    expenses: List[ExpenseItem]

    @validator("expenses")
    def validate_expenses(cls, v):
        if not v:
            raise ValueError("At least one expense must be provided.")
        return v

# Predefined suggested prompts
suggested_prompts = {
    "budgeting": "What's the best way to allocate my income for savings and spending?",
    "cost_saving": "How can I reduce my monthly expenses while maintaining my lifestyle?",
    "debt_management": "How should I prioritize paying off my debts while still saving money?",
    "investment_tips": "Based on my spending, what percentage of my income should go into investments?",
}

@router.post("/spending")
async def create_spending_plan(request: SpendingRequest):
    """
    POST /api/spending
    Expects JSON:
    {
        "monthly_income": 5000,
        "expenses": [
            {"category": "Rent", "amount": 1200},
            {"category": "Groceries", "amount": 400},
            {"category": "Transportation", "amount": 150},
            ...
        ]
    }
    Returns: { "plan": "...AI-generated budget plan...", "suggested_prompts": [...] }
    """

    # If the API key is missing or empty, we should log it (common source of error)
    if not openai.api_key:
        logging.error("OpenAI API key is not set. Please check your environment variables.")
        raise HTTPException(
            status_code=500,
            detail="OpenAI API key is missing or invalid. Please contact support."
        )

    user_expenses = "\n".join([f"- {item.category}: ${item.amount}" for item in request.expenses])
    user_message = (
        f"My monthly income is ${request.monthly_income}, and here’s my expense breakdown:\n"
        f"{user_expenses}\n\n"
        "Based on this data, suggest a better spending strategy. Identify areas to cut back and improve savings. "
        "Provide 2-3 actionable tips to optimize my budget."
    )

    try:
        # If you do not have GPT-4 access, change to model="gpt-3.5-turbo"
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
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
            "suggested_prompts": list(suggested_prompts.values())
        }

    except Exception as e:
        logging.exception("OpenAI error occurred in create_spending_plan")
        raise HTTPException(
            status_code=500,
            detail="An error occurred while generating your spending plan."
        ) from e
