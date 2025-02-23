import os
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import openai

from fastapi.responses import JSONResponse  # For UTF-8 response

load_dotenv()
logging.basicConfig(level=logging.INFO)

# Đảm bảo đã thiết lập OPENAI_API_KEY
openai.api_key = os.getenv("OPENAI_API_KEY")
if not openai.api_key:
    raise RuntimeError("Thiếu OpenAI API key! Vui lòng đặt OPENAI_API_KEY trong biến môi trường.")

router = APIRouter()

class NewsRequest(BaseModel):
    topic: str

@router.post("/news")
async def get_financial_news(request: NewsRequest) -> JSONResponse:
    """
    POST /api/news
    Dữ liệu JSON cần: { "topic": "cổ phiếu" }
    Trả về: { "analysis": "...Phân tích tin tức từ AI (tiếng Việt)..." }
    """

    if not request.topic.strip():
        raise HTTPException(
            status_code=400,
            detail="Vui lòng nhập chủ đề hợp lệ."
        )

    # Tin nhắn người dùng (tiếng Việt)
    user_message = (
        f"Tôi muốn bản phân tích ngắn gọn về tin tức tài chính gần đây liên quan đến '{request.topic}'. "
        "Hãy ngắn gọn, nêu những xu hướng chính và phản hồi 100% bằng tiếng Việt."
    )

    try:
        # Sử dụng ChatCompletion với openai>=1.0.0
        ai_response = openai.chat.completions.create(
            model="gpt-4-turbo",  # Hoặc "gpt-4" nếu có quyền
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Bạn là 'Cộng sự Tin tức', một AI chuyên về tin tức tài chính, "
                        "xu hướng thị trường. Trả lời bằng tiếng Việt, súc tích, rõ ràng."
                    )
                },
                {"role": "user", "content": user_message}
            ],
            max_tokens=1000,
            temperature=0.7
        )

        # Nếu API trả về bình thường
        if ai_response.choices and len(ai_response.choices) > 0:
            raw_reply = ai_response.choices[0].message.content.strip()
            # Encode/Decode để đảm bảo UTF-8
            ai_reply = raw_reply.encode("utf-8", "replace").decode("utf-8", "replace")
        else:
            ai_reply = "Không nhận được phản hồi từ AI."

        return JSONResponse(
            content={"analysis": ai_reply},
            media_type="application/json; charset=utf-8"
        )

    except Exception as e:
        logging.exception("Đã xảy ra lỗi khi gọi OpenAI trong news_agent")
        raise HTTPException(
            status_code=500,
            detail="Không thể lấy tin tức từ AI. Thử lại sau."
        ) from e
