from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text, func
from sqlalchemy.orm import relationship
from app.database import Base

class TradeFinanceQuery(Base):
    __tablename__ = "trade_finance_queries"

    id = Column(Integer, primary_key=True, index=True)
    origin_country = Column(String, nullable=False)
    destination_country = Column(String, nullable=False)
    commodity_description = Column(String, nullable=False)
    invoice_amount = Column(Float, nullable=False)
    
    # New columns
    task = Column(String, nullable=True)  # e.g., 'Generate LC', 'Risk Analysis'
    recommendation = Column(Text, nullable=True)
    chain_of_thought = Column(Text, nullable=True)  # If you want to store multi-step reasoning
    created_at = Column(DateTime, server_default=func.now())

    # Relationship to docs
    documents = relationship("TradeFinanceDoc", back_populates="query")

class TradeFinanceDoc(Base):
    __tablename__ = "trade_finance_docs"

    id = Column(Integer, primary_key=True, index=True)
    query_id = Column(Integer, ForeignKey("trade_finance_queries.id"), nullable=False)
    filename = Column(String, nullable=False)
    content_type = Column(String, nullable=True)
    file_content = Column(Text, nullable=True)  # Storing raw text; for PDFs you can store text or a path to the file

    query = relationship("TradeFinanceQuery", back_populates="documents")
