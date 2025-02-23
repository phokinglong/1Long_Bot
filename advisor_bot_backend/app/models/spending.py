from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime

class Income(Base):
    __tablename__ = "income"

    id = Column(Integer, primary_key=True, index=True)
    monthly_income = Column(Float, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    expenses = relationship("Expense", back_populates="income", cascade="all, delete-orphan")

class Expense(Base):
    __tablename__ = "expenses"

    id = Column(Integer, primary_key=True, index=True)
    category = Column(String, nullable=False)
    amount = Column(Float, nullable=False)
    income_id = Column(Integer, ForeignKey("income.id"), nullable=False)

    income = relationship("Income", back_populates="expenses")
