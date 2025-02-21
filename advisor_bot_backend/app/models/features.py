from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, TIMESTAMP
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from config.database import Base

class Feature(Base):
    __tablename__ = "features"

    id = Column(Integer, primary_key=True, index=True)
    agent_id = Column(Integer, ForeignKey("agents.id", ondelete="CASCADE"))
    feature_name = Column(String(255), nullable=False)
    enabled = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP, server_default=func.now())
    name = Column(String(255), nullable=False, unique=True)


    # Relationships
    agent = relationship("Agent", back_populates="features")
    faqs = relationship("FAQ", back_populates="category")

