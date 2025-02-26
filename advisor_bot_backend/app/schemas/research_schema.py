from pydantic import BaseModel, Field
from typing import List

# The user can pass a stock symbol, plus a list of metrics to gather
class ResearchMetricItem(BaseModel):
    metric_name: str  # e.g. "income_statement", "cash_flow", etc.

class ResearchRequest(BaseModel):
    stock_symbol: str = Field(..., description="Stock ticker/symbol in Vietnamese market")
    metrics: List[ResearchMetricItem] = Field(
        ..., description="List of financial metrics the user wants to see"
    )

class ResearchResponse(BaseModel):
    stock_symbol: str
    metrics: List[str]  # which metrics were used
    analysis: str       # AI-provided or combined results
