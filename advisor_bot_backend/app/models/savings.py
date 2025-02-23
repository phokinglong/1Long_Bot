from sqlalchemy import Column, Integer, Float, Text
from config.database import Base

class SavingsPlan(Base):
    __tablename__ = "savings_plans"

    id = Column(Integer, primary_key=True, index=True)
    goal_amount = Column(Float, nullable=False)
    months = Column(Integer, nullable=False)
    monthly_savings = Column(Float, nullable=False)  # ✅ Ensure this exists
    motivational_tips = Column(Text, nullable=True)  # ✅ Now works

