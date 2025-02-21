from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.models.faq_model import FAQStatic, FAQDynamic
from app.schemas.faq_schema import FAQResponse
from app.database import get_db
import openai

router = APIRouter()

def load_faqs(db: Session):
    """ Load FAQs from faqs_static first """
    faqs = db.query(FAQStatic).all()
    faq_vectors = [model.encode(faq.question) for faq in faqs]
    
    index = faiss.IndexFlatL2(384)
    if faq_vectors:
        index.add(np.array(faq_vectors))

    return faqs, index

def search_faq(db: Session, user_query: str):
    """ Search both faqs_static (official) and faqs_dynamic (approved) """
    faqs_static, index_static = load_faqs(db)
    
    query_vector = model.encode(user_query).reshape(1, -1)
    _, index_matches = index_static.search(query_vector, k=1)

    if index_matches[0][0] >= 0:
        return faqs_static[index_matches[0][0]].answer  # Return best FAQ answer

    # If not found in faqs_static, check faqs_dynamic (approved responses)
    dynamic_faq = db.query(FAQDynamic).filter(
        FAQDynamic.question.ilike(f"%{user_query}%"),
        FAQDynamic.approved == True
    ).first()

    if dynamic_faq:
        return dynamic_faq.answer

    return None

@router.post("/faq/")
def get_faq_answer(user_query: str, db: Session = Depends(get_db)):
    """ Check faqs_static first, then faqs_dynamic, then call AI """
    answer = search_faq(db, user_query)
    
    if answer:
        return {"answer": answer}
    
    # If no FAQ found, call AI
    ai_response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": user_query}]
    )

    ai_answer = ai_response["choices"][0]["message"]["content"]

    # Store AI response in faqs_dynamic for admin approval
    new_faq = FAQDynamic(question=user_query, answer=ai_answer, approved=False)
    db.add(new_faq)
    db.commit()

    return {"answer": ai_answer, "note": "AI-generated response, pending approval"}
