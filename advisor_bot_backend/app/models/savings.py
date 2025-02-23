from sqlalchemy import Column, Integer, Float
from config.database import Base

class SavingsPlan(Base):
    __tablename__ = "savings_plans"

    id = Column(Integer, primary_key=True, index=True)
    goal_amount = Column(Float, nullable=False)  # Ensure this exists
    months = Column(Integer, nullable=False)  # Ensure this exists
