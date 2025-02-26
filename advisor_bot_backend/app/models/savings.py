# app/models/savings.py

from sqlalchemy import Column, Integer, Float, String, ForeignKey, DateTime, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base

class SavingsPlan(Base):
    __tablename__ = "savings_plans"

    id = Column(Integer, primary_key=True, index=True)
    
    # 1. Basic fields
    goal_name = Column(String(255), nullable=False)       # e.g. "Mua xe", "Quỹ học"
    goal_amount = Column(Float, nullable=False)           # e.g. 100000000 VNĐ
    months = Column(Integer, nullable=False)              # e.g. 12
    monthly_savings = Column(Float, nullable=False)       # e.g. 8333333.33
    motivational_tips = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # 2. Advanced fields for your new feature
    # If the user wants to specify an annual return rate (5% -> 0.05)
    desired_return_rate = Column(Float, nullable=False, default=0.0)

    # If you want to link to a user (uncomment if you want user scoping):
    # user_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    # Optionally, if you want to store a 'month_by_month' JSON, you could do:
    # month_by_month = Column(Text, nullable=True)
    # which you'll store a JSON string from Python (list of {month, amount})
