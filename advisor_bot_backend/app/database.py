from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session

# Database URL (Update with your actual database URL)
DATABASE_URL = "postgresql://postgres:1long123!@localhost/financial_bot"

# Create the database engine
engine = create_engine(DATABASE_URL)

# Create a configured "SessionLocal" class
SessionLocal = scoped_session(sessionmaker(autocommit=False, autoflush=False, bind=engine))

# Create a base class for models
Base = declarative_base()

# Dependency to get a database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
