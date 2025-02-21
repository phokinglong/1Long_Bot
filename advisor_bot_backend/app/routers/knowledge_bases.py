from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from config.database import get_db
from app.models.knowledge_bases import KnowledgeBase
from app.models.agents import Agent
from pydantic import BaseModel

router = APIRouter()

# Pydantic Model for Knowledge Base Entry Input
class KnowledgeBaseCreate(BaseModel):
    agent_id: int
    topic: str
    content: str

# Pydantic Model for Knowledge Base Output
class KnowledgeBaseResponse(KnowledgeBaseCreate):
    id: int

    class Config:
        orm_mode = True

# Create a new knowledge base entry
@router.post("/knowledge_bases/", response_model=KnowledgeBaseResponse)
def create_knowledge_entry(entry: KnowledgeBaseCreate, db: Session = Depends(get_db)):
    # Check if agent exists
    agent = db.query(Agent).filter(Agent.id == entry.agent_id).first()
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")

    db_entry = KnowledgeBase(agent_id=entry.agent_id, topic=entry.topic, content=entry.content)
    db.add(db_entry)
    db.commit()
    db.refresh(db_entry)
    return db_entry

# Get all knowledge base entries
@router.get("/knowledge_bases/", response_model=List[KnowledgeBaseResponse])
def get_knowledge_entries(db: Session = Depends(get_db)):
    return db.query(KnowledgeBase).all()

# Get a specific knowledge base entry by ID
@router.get("/knowledge_bases/{entry_id}", response_model=KnowledgeBaseResponse)
def get_knowledge_entry(entry_id: int, db: Session = Depends(get_db)):
    entry = db.query(KnowledgeBase).filter(KnowledgeBase.id == entry_id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Knowledge entry not found")
    return entry

# Update a knowledge base entry
@router.put("/knowledge_bases/{entry_id}", response_model=KnowledgeBaseResponse)
def update_knowledge_entry(entry_id: int, entry_update: KnowledgeBaseCreate, db: Session = Depends(get_db)):
    entry = db.query(KnowledgeBase).filter(KnowledgeBase.id == entry_id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Knowledge entry not found")

    entry.agent_id = entry_update.agent_id
    entry.topic = entry_update.topic
    entry.content = entry_update.content
    db.commit()
    db.refresh(entry)
    return entry

# Delete a knowledge base entry
@router.delete("/knowledge_bases/{entry_id}")
def delete_knowledge_entry(entry_id: int, db: Session = Depends(get_db)):
    entry = db.query(KnowledgeBase).filter(KnowledgeBase.id == entry_id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Knowledge entry not found")

    db.delete(entry)
    db.commit()
    return {"message": "Knowledge entry deleted successfully"}
