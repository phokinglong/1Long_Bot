import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class Settings:
    DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:1long123!@localhost/financial_bot")

settings = Settings()
