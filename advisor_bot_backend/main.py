from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config.database import Base, engine
from app.routers.agents import router as agent_router
from app.routers.knowledge_bases import router as knowledge_router
from app.routers.features import router as feature_router
from app.routers.ai_chat import router as ai_router
from app.auth.auth import router as auth_router
from config.database import Base, engine
from app.routers.faq import router as faq_router
from app.routers.savings_agent import router as savings_router
from app.routers.investment_agent import router as investment_router
from app.routers.spending_agent import router as spending_router
from app.routers.news_agent import router as news_router

# Initialize FastAPI app
app = FastAPI()

# Enable CORS (Fixes connection issues with Flutter Web)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins, change this for better security
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods (GET, POST, etc.)
    allow_headers=["*"],  # Allow all headers
)

# Create tables if they don't exist
Base.metadata.create_all(bind=engine)

# Register Routers
app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(agent_router, prefix="/api/agents", tags=["Agents"])  # Ensure API structure is correct
app.include_router(knowledge_router, prefix="/api/knowledge", tags=["Knowledge Base"])
app.include_router(feature_router, prefix="/api/features", tags=["Features"])
app.include_router(ai_router, prefix="/api", tags=["AI Chat"])
app.include_router(faq_router, prefix="/api", tags=["FAQ"])
app.include_router(spending_router, prefix="/api", tags=["Spending Agent"])
app.include_router(savings_router, prefix="/api", tags=["Savings Agent"])
app.include_router(investment_router, prefix="/api", tags=["Investment Agent"])
app.include_router(news_router, prefix="/api", tags=["News Agent"])

# Root endpoint
@app.get("/")
def read_root():
    return {"message": "Financial Advisor Bot API is running!"}
