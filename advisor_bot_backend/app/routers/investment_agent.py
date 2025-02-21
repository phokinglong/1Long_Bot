import os
import logging

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import openai

load_dotenv()
logging.basicConfig(level=logging.INFO)

# Make sure you set the API key from env somewhere (if not done globally)
openai.api_key = os.getenv("OPENAI_API_KEY")

router = APIRouter()

class InvestmentRequest(BaseModel):
    initial_investment: float
    risk_tolerance: str  # e.g. "low", "medium", "high" 

@router.post("/investment")
async def create_investment_plan(request: InvestmentRequest):
    """
    POST /api/investment
    Expects JSON like: {
      "initial_investment": 10000,
      "risk_tolerance": "medium"
    }
    Returns JSON: { "plan": "...AI Advice..." }
    """

    logging.warning("openai.api_key: %s", openai.api_key)

    if request.initial_investment <= 0:
        raise HTTPException(
            status_code=400,
            detail="initial_investment must be positive."
        )
    # simple check for risk_tolerance
    if request.risk_tolerance.lower() not in ["low", "medium", "high"]:
        raise HTTPException(
            status_code=400,
            detail="risk_tolerance must be one of: low, medium, high."
        )

    user_message = (
        f"I have an initial investment of {request.initial_investment} USD. "
        f"My risk tolerance is {request.risk_tolerance}. "
        "Can you provide a brief investment strategy outline?"
    )

    try:
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",  # or gpt-4 if you have access
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are 'Cộng sự Đầu tư', a friendly investment advisor. "
                        "Provide a concise but actionable plan on how to invest "
                        "the given amount based on the user's risk tolerance. "
                        "Include suggested asset allocation and a short rationale."
                    )
                },
                {"role": "user", "content": user_message},
            ],
            max_tokens=400,
            temperature=0.7
        )

        ai_reply = response.choices[0].message.content
        return {"plan": ai_reply}

    except Exception as e:
        logging.exception("OpenAI error occurred")
        raise HTTPException(status_code=500, detail=str(e)) from e
