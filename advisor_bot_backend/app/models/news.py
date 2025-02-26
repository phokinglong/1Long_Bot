# app/models/news.py

from sqlalchemy import Column, Integer, String, ForeignKey, Text, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base

class News(Base):
    __tablename__ = "news"

    id = Column(Integer, primary_key=True, index=True)
    topic = Column(String, nullable=False)
    analysis = Column(Text, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # NEW field for linking to a user
    created_at = Column(DateTime, default=datetime.utcnow)

    # Optionally, define a relationship to the User model if needed
    # user = relationship("User", back_populates="news")
