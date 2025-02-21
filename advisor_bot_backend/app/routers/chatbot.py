from fastapi import APIRouter, HTTPException
from app.services.ai_service import get_ai_response
from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

router = APIRouter()

@router.post("/chatbot/", dependencies=[Depends(oauth2_scheme)])
async def chatbot_query(query: dict):
    user_input = query.get("message")
    if not user_input:
        raise HTTPException(status_code=400, detail="No message provided")

    response = get_ai_response(user_input)
    return {"response": response}
