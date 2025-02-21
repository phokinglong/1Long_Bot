from pydantic import BaseModel

class FAQResponse(BaseModel):
    id: int
    question: str
    answer: str
    approved: bool

    class Config:
        from_attributes = True  # ✅ Ensure compatibility with Pydantic v2
