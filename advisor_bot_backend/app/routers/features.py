from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from config.database import get_db
from app.models.features import Feature
from app.models.agents import Agent
from pydantic import BaseModel

router = APIRouter()

# Pydantic Model for Feature Input
class FeatureCreate(BaseModel):
    agent_id: int
    feature_name: str
    enabled: bool = True

# Pydantic Model for Feature Output
class FeatureResponse(FeatureCreate):
    id: int

    class Config:
        orm_mode = True

# Create a new feature
@router.post("/features/", response_model=FeatureResponse)
def create_feature(feature: FeatureCreate, db: Session = Depends(get_db)):
    # Check if agent exists
    agent = db.query(Agent).filter(Agent.id == feature.agent_id).first()
    if not agent:
        raise HTTPException(status_code=404, detail="Agent not found")

    db_feature = Feature(agent_id=feature.agent_id, feature_name=feature.feature_name, enabled=feature.enabled)
    db.add(db_feature)
    db.commit()
    db.refresh(db_feature)
    return db_feature

# Get all features
@router.get("/features/", response_model=List[FeatureResponse])
def get_features(db: Session = Depends(get_db)):
    return db.query(Feature).all()

# Get features for a specific agent
@router.get("/features/agent/{agent_id}", response_model=List[FeatureResponse])
def get_features_by_agent(agent_id: int, db: Session = Depends(get_db)):
    return db.query(Feature).filter(Feature.agent_id == agent_id).all()

# Toggle a feature ON/OFF
@router.put("/features/{feature_id}", response_model=FeatureResponse)
def update_feature(feature_id: int, feature_update: FeatureCreate, db: Session = Depends(get_db)):
    feature = db.query(Feature).filter(Feature.id == feature_id).first()
    if not feature:
        raise HTTPException(status_code=404, detail="Feature not found")

    feature.agent_id = feature_update.agent_id
    feature.feature_name = feature_update.feature_name
    feature.enabled = feature_update.enabled
    db.commit()
    db.refresh(feature)
    return feature

# Delete a feature
@router.delete("/features/{feature_id}")
def delete_feature(feature_id: int, db: Session = Depends(get_db)):
    feature = db.query(Feature).filter(Feature.id == feature_id).first()
    if not feature:
        raise HTTPException(status_code=404, detail="Feature not found")

    db.delete(feature)
    db.commit()
    return {"message": "Feature deleted successfully"}
