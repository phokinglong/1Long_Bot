# app/routers/news_agent.py

import os
import logging
import requests
from bs4 import BeautifulSoup
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import openai

from fastapi.responses import JSONResponse  # For UTF-8 response

load_dotenv()
logging.basicConfig(level=logging.INFO)

openai.api_key = os.getenv("OPENAI_API_KEY")
if not openai.api_key:
    raise RuntimeError("Missing OPENAI_API_KEY in environment")

router = APIRouter()

class NewsRequest(BaseModel):
    topic: str

# Example list of finance/business websites to search
FINANCE_SITES = [
    "https://markettimes.vn/",
    "https://vietstock.vn/",
    "https://cafef.vn/",
    "https://vneconomy.vn/",
]

def fetch_latest_articles(topic: str):
    """
    Very naive approach: fetch front pages of known sites,
    search for `topic` in the HTML, return limited article info.
    In real usage, you'd parse the actual article listings or use site search.
    """
    articles = []  # We'll store dictionaries: {"title": "...", "url": "..."}
    for site_url in FINANCE_SITES:
        try:
            r = requests.get(site_url, timeout=5)
            if r.status_code == 200:
                soup = BeautifulSoup(r.text, "html.parser")
                # We'll find <a> tags that contain the topic in text or something naive
                all_links = soup.find_all("a")
                for link in all_links:
                    text = link.get_text().strip()
                    href = link.get("href")
                    if not href or not text:
                        continue
                    # Suppose we check if topic is in the text, ignoring case
                    if topic.lower() in text.lower():
                        # Build a short article record
                        full_link = href
                        # If href is relative, fix it:
                        if href.startswith("/"):
                            full_link = site_url.rstrip("/") + href
                        articles.append({
                            "title": text[:150],  # limit length
                            "url": full_link
                        })
            else:
                logging.warning(f"Failed to fetch {site_url}, status: {r.status_code}")
        except Exception as e:
            logging.exception(f"Error fetching {site_url}: {e}")
    return articles

@router.post("/news")
async def get_financial_news(request: NewsRequest) -> JSONResponse:
    """
    POST /api/news
    Expects JSON: { "topic": "Samsung" }
    Returns: { "analysis": "...AI summary in Vietnamese...",
               "articles": [ { "title": "...", "url": "..." }, ... ] }
    """
    topic = request.topic.strip()
    if not topic:
        raise HTTPException(status_code=400, detail="Vui lòng nhập chủ đề hợp lệ.")

    # 1) Fetch articles from known finance sites
    articles_found = fetch_latest_articles(topic)

    if not articles_found:
        # If we found no articles, we can just return a GPT general message
        return JSONResponse(
            content={
                "analysis": f"Không tìm thấy tin tức liên quan đến '{topic}' trên các trang.",
                "articles": []
            },
            media_type="application/json; charset=utf-8"
        )

    # 2) Summarize articles with GPT
    # We'll create a small text snippet from the found articles
    # For each article, we do: "Title: ... \nURL: ..."
    snippet_str = "\n".join(
        [f"- {art['title']} (Link: {art['url']})" for art in articles_found[:5]]
    )

    user_prompt = (
        f"Tôi muốn tóm tắt các tin tức mới nhất về '{topic}' tìm thấy trên một số trang. "
        f"Dưới đây là danh sách tiêu đề (có link). Hãy viết một đoạn phân tích ngắn gọn, "
        f"điểm qua xu hướng chính và tuyệt đối trả lời bằng tiếng Việt.\n\n"
        f"{snippet_str}"
    )

    try:
        response = openai.chat.completions.create(
            model="gpt-4-turbo",  # or "gpt-3.5-turbo"
            messages=[
                {
                    "role": "system",
                    "content": (
                        "Bạn là 'Cộng sự Tin tức', một AI chuyên về tin tức tài chính. "
                        "Luôn trả lời ngắn gọn, 100% bằng tiếng Việt."
                    )
                },
                {"role": "user", "content": user_prompt}
            ],
            max_tokens=700,
            temperature=0.7
        )

        if len(response.choices) > 0:
            raw_reply = response.choices[0].message.content.strip()
            analysis = raw_reply.encode("utf-8", "replace").decode("utf-8", "replace")
        else:
            analysis = "Không nhận được phản hồi từ GPT."

    except Exception as e:
        logging.exception("OpenAI error in advanced news plan")
        analysis = (
            f"Lỗi khi gọi GPT: {str(e)}. "
            f"Dưới đây là danh sách bài viết thô:\n{snippet_str}"
        )

    # 3) Return JSON with GPT analysis + short article list
    return JSONResponse(
        content={
            "analysis": analysis,
            "articles": articles_found[:5]  # only return top 5
        },
        media_type="application/json; charset=utf-8"
    )
