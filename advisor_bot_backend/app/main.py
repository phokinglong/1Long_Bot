# advisor_bot_backend/app/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config.database import Base, engine

# Import only finished routers
from app.routers.savings_agent import router as savings_router
from app.routers.investment_agent import router as investment_router
from app.routers.news_agent import router as news_router
from app.routers.spending_agent import router as spending_router  # Keeping spending!

# Initialize FastAPI app
app = FastAPI()

# Enable CORS (Fixes connection issues with Flutter/Web)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (change for better security)
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)

# Create database tables if they don't exist
Base.metadata.create_all(bind=engine)

# Register essential agent routers
app.include_router(savings_router, prefix="/api", tags=["Savings Agent"])
app.include_router(investment_router, prefix="/api", tags=["Investment Agent"])
app.include_router(news_router, prefix="/api", tags=["News Agent"])
app.include_router(spending_router, prefix="/api", tags=["Spending Agent"])  # Using spending

# Root endpoint to check if API is running
@app.get("/")
def read_root():
    return {"message": "Financial Advisor Bot API is running!"}
