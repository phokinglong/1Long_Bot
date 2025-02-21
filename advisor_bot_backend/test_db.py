from config.database import SessionLocal
from sqlalchemy.sql import text  # Import the correct text function

def test_connection():
    db = SessionLocal()
    try:
        db.execute(text("SELECT 1"))  # Use text() for raw SQL
        print("Database connection successful!")
    except Exception as e:
        print("Database connection failed:", e)
    finally:
        db.close()

test_connection()
