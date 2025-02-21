from sqlalchemy import Column, Integer, String, Text, Boolean, ForeignKey, TIMESTAMP
from sqlalchemy.sql import func
from ..database import Base

# ✅ Static FAQ Table (Pre-approved FAQs)
class FAQStatic(Base):
    __tablename__ = "faqs_static"

    id = Column(Integer, primary_key=True, index=True)
    category_id = Column(Integer, ForeignKey("categories.id"))
    question = Column(Text, unique=True, nullable=False)
    answer = Column(Text, nullable=False)
    source_url = Column(String, nullable=True)
    created_at = Column(TIMESTAMP, server_default=func.now())

# ✅ Dynamic FAQ Table (User-generated and AI Responses)
class FAQDynamic(Base):
    __tablename__ = "faqs_dynamic"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)  # Nullable for AI-generated responses
    question = Column(Text, nullable=False)
    answer = Column(Text, nullable=False)
    approved = Column(Boolean, default=False)  # Must be manually approved
    created_at = Column(TIMESTAMP, server_default=func.now())
