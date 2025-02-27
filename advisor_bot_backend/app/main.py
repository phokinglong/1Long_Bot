from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config.database import Base, engine

# Import only finished routers
from app.routers.savings_agent import router as savings_router
from app.routers.investment_agent import router as investment_router
from app.routers.news_agent import router as news_router
from app.routers.spending_agent import router as spending_router  # Keeping spending!
from app.routers.research_agent import router as research_router
from app.routers.trade_finance_router import trade_finance_router


# Initialize FastAPI app
app = FastAPI()

# Allow frontend requests (Replace with your actual frontend URL)
origins = [
    "http://localhost:*",  # Allow all localhost ports (Flutter hot reload uses dynamic ports)
    "http://127.0.0.1:8000",  # Ensure backend allows self-calls
    "http://localhost:3000",  # React frontend (if applicable)
    "http://localhost:53531",  # Your Flutter frontend
    "https://your-frontend-domain.com",  # Production frontend (Update this)
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development, allow all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create database tables if they don't exist
def startup_db():
    Base.metadata.create_all(bind=engine)

# Register routers with specific prefixes:
app.include_router(savings_router, prefix="/api", tags=["Savings Agent"])
app.include_router(investment_router, prefix="/api", tags=["Investment Agent"])
app.include_router(news_router, prefix="/api", tags=["News Agent"])
app.include_router(spending_router, prefix="/api", tags=["Spending Agent"])
app.include_router(research_router, prefix="/api", tags=["Research Agent"])
app.include_router(trade_finance_router)

# Root endpoint to check if API is running
@app.get("/")
def read_root():
    return {"message": "Financial Advisor Bot API is running!"}
