# app/models/user.py

from sqlalchemy import Column, Integer, String, DateTime, func
from app.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    # Additional fields can be added (e.g., phone, etc.)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
