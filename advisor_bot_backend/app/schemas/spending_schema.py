# advisor_bot_backend/app/schemas/spending_schema.py

from pydantic import BaseModel, Field
from typing import List

class ExpenseItem(BaseModel):
    category: str
    amount: float = Field(..., gt=0, description="Expense amount must be positive")

class SpendingRequest(BaseModel):
    user_id: int
    monthly_income: float = Field(..., gt=0, description="Monthly income must be positive")
    expenses: List[ExpenseItem]
