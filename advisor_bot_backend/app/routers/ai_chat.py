from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from config.database import get_db
from app.services.ai_service_engine import ask_ai
from app.models.knowledge_bases import KnowledgeBase
from app.models.agents import Agent
from pydantic import BaseModel

router = APIRouter()

# Pydantic Model for AI Query
class AIQuery(BaseModel):
    agent_id: int
    question: str

# AI Chat Endpoint
@router.post("/ai_chat/")
def chat_with_ai(query: AIQuery, db: Session = Depends(get_db)):
    # Check if agent exists
    agent = db.query(Agent).filter(Agent.id == query.agent_id).first()
    if not agent:
        raise HTTPException(status_code=404, detail=f"Agent with id {query.agent_id} not found")

    # Retrieve knowledge base for the agent
    knowledge_entries = db.query(KnowledgeBase).filter(KnowledgeBase.agent_id == query.agent_id).all()
    
    if not knowledge_entries:
        raise HTTPException(status_code=404, detail=f"No knowledge base found for Agent ID {query.agent_id}")

    # Combine all knowledge into a single string
    knowledge_base_text = "\n".join([entry.content for entry in knowledge_entries])

    # Get AI response
    ai_response = ask_ai(query.question, knowledge_base_text)

    return {
        "agent_id": query.agent_id,
        "question": query.question,
        "response": ai_response,
        "knowledge_used": knowledge_base_text
    }

