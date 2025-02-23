# app/models/investment.py

import enum
from sqlalchemy import Column, Integer, Float, String, Enum, Text, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class AssetType(enum.Enum):
    stock = "stock"
    real_estate = "real_estate"
    gold = "gold"
    bank_deposit = "bank_deposit"

class InvestmentPortfolio(Base):
    __tablename__ = "investment_portfolios"
    id = Column(Integer, primary_key=True, index=True)
    risk_tolerance = Column(String(50), nullable=False)
    # Relationship to assets
    assets = relationship("Asset", back_populates="portfolio", cascade="all, delete-orphan")

class Asset(Base):
    __tablename__ = "assets"
    id = Column(Integer, primary_key=True, index=True)
    portfolio_id = Column(Integer, ForeignKey("investment_portfolios.id"), nullable=False)
    asset_type = Column(Enum(AssetType), nullable=False)
    value = Column(Float, nullable=False)

    portfolio = relationship("InvestmentPortfolio", back_populates="assets")
