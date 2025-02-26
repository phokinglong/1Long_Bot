import enum
from sqlalchemy import Column, Integer, String, Text, Enum, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base

# Optional: If you want to store the “metrics” in an Enum or as a simple text
class MetricType(enum.Enum):
    INCOME_STATEMENT = "income_statement"
    CASH_FLOW = "cash_flow"
    BALANCE_SHEET = "balance_sheet"
    FINANCIAL_SUMMARY = "financial_summary"

class ResearchQuery(Base):
    __tablename__ = "research_queries"

    id = Column(Integer, primary_key=True, index=True)
    stock_symbol = Column(String(20), nullable=False)
    # For simplicity, store the user’s chosen metrics as text.
    selected_metrics = Column(Text, nullable=True)
    result = Column(Text, nullable=True)  # AI response or analysis
    created_at = Column(DateTime, default=datetime.utcnow)

    # If you want to associate with a user
    # user_id = Column(Integer, ForeignKey("users.id"))
    # user = relationship("User", back_populates="research_queries")
