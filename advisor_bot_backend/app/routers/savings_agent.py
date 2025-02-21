# app/routers/savings_agent.py

import os
import logging

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import openai

# 1. Load environment variables from .env
load_dotenv()

# 2. Set up logging
logging.basicConfig(level=logging.INFO)

# 3. Set openai.api_key using env variable
openai.api_key = os.getenv("OPENAI_API_KEY")

router = APIRouter()

# 4. Define your Pydantic model
class SavingsRequest(BaseModel):
    goal_amount: float
    months: int

@router.post("/savings")
async def create_savings_plan(request: SavingsRequest):
    """
    POST /api/savings
    Expects JSON: { "goal_amount": 5000, "months": 10 }
    Returns: { "plan": "...AI response..." }
    """

    # Debug logs to confirm the key is set
    logging.warning("OpenAI key from env: %s", os.getenv("OPENAI_API_KEY"))
    logging.warning("openai.api_key in code: %s", openai.api_key)

    if request.goal_amount <= 0 or request.months <= 0:
        raise HTTPException(
            status_code=400,
            detail="goal_amount and months must be positive."
        )

    user_message = (
        f"I have a savings goal of {request.goal_amount} USD in {request.months} months. "
        "Please calculate how much I need to save each month and give me 1-2 motivational tips."
    )

    try:
        # NOTE: The new openai library uses openai.chat.completions.create(...)
        # instead of openai.ChatCompletion.create(...)
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",  # or "gpt-4" if you have access
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are 'Cộng sự Tích lũy', a friendly savings advisor. "
                        "Give a concise monthly saving plan, plus a couple motivational tips."
                    )
                },
                {"role": "user", "content": user_message},
            ],
            max_tokens=300,
            temperature=0.7
        )

        # Access the AI's reply
        ai_reply = response.choices[0].message.content 
        return {"plan": ai_reply}

    except Exception as e:
        # Log the full traceback for debugging
        logging.exception("OpenAI error occurred")
        # Return the actual error message in the response to see what's going on
        raise HTTPException(status_code=500, detail=str(e)) from e
