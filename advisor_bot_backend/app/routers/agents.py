from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from config.database import get_db
from app.models.agents import Agent
from app.auth.auth import get_current_user  # Import authentication dependency
from pydantic import BaseModel

router = APIRouter()

# Pydantic Model for Agent Input
class AgentCreate(BaseModel):
    name: str
    personality: str

# Pydantic Model for Agent Output
class AgentResponse(AgentCreate):
    id: int

    class Config:
        orm_mode = True

# Create a new agent (Protected: Requires authentication)
@router.post("/agents/", response_model=AgentResponse)
def create_agent(agent: AgentCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    db_agent = Agent(name=agent.name, personality=agent.personality)
    db.add(db_agent)
    db.commit()
    db.refresh(db_agent)
    return db_agent

# Get all agents (Public)
@router.get("/agents/", response_model=List[AgentResponse])
def get_agents(db: Session = Depends(get_db)):
    return db.query(Agent).all()

# Get a single agent by ID (Public)
@router.get("/agents/{agent_id}", response_model=AgentResponse)
def get_agent(agent_id: int, db: Session = Depends(get_db)):
    agent = db.query(Agent).filter(Agent.id == agent_id).first()
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    return agent

# Update an agent (Protected)
@router.put("/agents/{agent_id}", response_model=AgentResponse)
def update_agent(agent_id: int, agent_update: AgentCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    agent = db.query(Agent).filter(Agent.id == agent_id).first()
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    
    agent.name = agent_update.name
    agent.personality = agent_update.personality
    db.commit()
    db.refresh(agent)
    return agent

# Delete an agent (Protected)
@router.delete("/agents/{agent_id}")
def delete_agent(agent_id: int, db: Session = Depends(get_db), user=Depends(get_current_user)):
    agent = db.query(Agent).filter(Agent.id == agent_id).first()
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")
    
    db.delete(agent)
    db.commit()
    return {"message": "Agent deleted successfully"}
