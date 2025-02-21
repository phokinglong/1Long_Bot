from sqlalchemy import Column, Integer, String, ForeignKey, Text, TIMESTAMP, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from config.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    password_hash = Column(Text, nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())

class Bot(Base):
    __tablename__ = "bots"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, nullable=False)
    description = Column(Text)
    knowledge_base = Column(Text)  # Can store JSON or text
    features = Column(JSON)
    cot_prompts = Column(JSON)
    created_at = Column(TIMESTAMP, server_default=func.now())

class UserBot(Base):
    __tablename__ = "user_bots"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    bot_id = Column(Integer, ForeignKey("bots.id", ondelete="CASCADE"))
    selected_at = Column(TIMESTAMP, server_default=func.now())

class ChatHistory(Base):
    __tablename__ = "chat_history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    bot_id = Column(Integer, ForeignKey("bots.id", ondelete="CASCADE"))
    message = Column(Text, nullable=False)
    response = Column(Text, nullable=False)
    timestamp = Column(TIMESTAMP, server_default=func.now())
