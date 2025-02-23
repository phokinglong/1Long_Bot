import os
import logging
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
import openai
from dotenv import load_dotenv
from app.database import get_db
from app.models.savings import SavingsPlan

# Load environment variables
load_dotenv()

# Logging
logging.basicConfig(level=logging.INFO)

# Set OpenAI API Key
openai.api_key = os.getenv("OPENAI_API_KEY")

router = APIRouter()

# Request Model
class SavingsRequest(BaseModel):
    goal_amount: float
    months: int

# Response Model
class SavingsResponse(BaseModel):
    goal_amount: float
    months: int
    motivational_tips: str

@router.post("/savings")
async def create_savings_plan(request: SavingsRequest, db: Session = Depends(get_db)):
    """
    Create a savings plan, store it in DB, and return the AI-generated response.
    """
    if request.goal_amount <= 0 or request.months <= 0:
        raise HTTPException(status_code=400, detail="Goal amount and months must be positive.")

    monthly_savings = request.goal_amount / request.months
    user_message = (
        f"I want to save {request.goal_amount} USD in {request.months} months. "
        f"How much should I save each month? Give me 1-2 motivational tips."
    )

    try:
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a friendly savings advisor."},
                {"role": "user", "content": user_message},
            ],
            max_tokens=150,
            temperature=0.7
        )

        motivational_tips = response.choices[0].message.content.strip()

        # Store savings plan in the database
        savings_plan = SavingsPlan(
            goal_amount=request.goal_amount,
            months=request.months,
            monthly_savings=monthly_savings,
            motivational_tips=motivational_tips
        )
        db.add(savings_plan)
        db.commit()
        db.refresh(savings_plan)

        return {
            "goal_amount": savings_plan.goal_amount,
            "months": savings_plan.months,
            "monthly_savings": savings_plan.monthly_savings,
            "motivational_tips": savings_plan.motivational_tips
        }

    except Exception as e:
        logging.exception("OpenAI error occurred")
        raise HTTPException(status_code=500, detail=str(e))
