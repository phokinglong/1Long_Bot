import os
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import openai

# Load environment variables
load_dotenv()
logging.basicConfig(level=logging.INFO)

# Ensure OpenAI API key is set
openai.api_key = os.getenv("OPENAI_API_KEY")
if not openai.api_key:
    raise RuntimeError("OpenAI API key is missing! Set OPENAI_API_KEY in your environment.")

router = APIRouter()

class NewsRequest(BaseModel):
    topic: str

@router.post("/news")
async def get_financial_news(request: NewsRequest):
    """
    POST /api/news
    Expects JSON: { "topic": "stocks" }
    Returns: { "analysis": "...AI news summary..." }
    """

    if not request.topic.strip():
        raise HTTPException(
            status_code=400,
            detail="Please provide a valid topic for news."
        )

    user_message = (
        f"I want a short analysis of recent financial news related to {request.topic}. "
        "Keep it concise and highlight any major trends."
    )

    try:
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {
                    "role": "system",
                    "content": (
                        "You are 'Cộng sự Tin tức', an AI specialized in "
                        "financial news and market trends. Provide short, "
                        "clear summaries of the current news on the requested topic."
                    )
                },
                {"role": "user", "content": user_message}
            ],
            max_tokens=400,
            temperature=0.7
        )

        # Ensure response structure is valid
        if response.choices and len(response.choices) > 0:
            ai_reply = response.choices[0].message.content
        else:
            ai_reply = "No response from AI."

        return {"analysis": ai_reply}

    except Exception as e:
        logging.exception("OpenAI error occurred in news_agent")
        raise HTTPException(status_code=500, detail="AI generation failed. Please try again later.")
