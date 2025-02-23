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

# Allow frontend requests (Replace with your actual frontend URL)
origins = [
    "http://localhost:*",   # Allow any localhost port for development
    "https://your-frontend-domain.com",  # Your deployed frontend
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development, allow all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create database tables if they don't exist
Base.metadata.create_all(bind=engine)

# Register routers with specific prefixes:
app.include_router(savings_router, prefix="/api", tags=["Savings Agent"])
app.include_router(investment_router, prefix="/api/investment", tags=["Investment Agent"])
app.include_router(news_router, prefix="/api", tags=["News Agent"])
app.include_router(spending_router, prefix="/api", tags=["Spending Agent"])

# Root endpoint to check if API is running
@app.get("/")
def read_root():
    return {"message": "Financial Advisor Bot API is running!"}
