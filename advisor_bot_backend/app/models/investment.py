from sqlalchemy import Column, Integer, Float, String
from app.database import Base

class Investment(Base):
    __tablename__ = "investments"

    id = Column(Integer, primary_key=True, index=True)
    amount = Column(Float, nullable=False)
    risk_level = Column(String, nullable=False)
