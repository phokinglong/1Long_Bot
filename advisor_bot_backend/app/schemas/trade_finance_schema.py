from pydantic import BaseModel
from typing import Optional

class TradeFinanceInput(BaseModel):
    origin_country: str
    destination_country: str
    commodity_description: str
    invoice_amount: float
    prompt_id: int  # User picks a prompt 1..10

class TradeFinanceOutput(BaseModel):
    prompt_used: str
    combined_prompt: str
    ai_response: str
