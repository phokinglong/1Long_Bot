import sys
import os
import importlib
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context

# Ensure app directory is in the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'app')))

# Import Base and all models
from app.database import Base
from config.settings import settings

# Import all models explicitly
# Import all models to be recognized by Alembic
from app.models.spending import Income, Expense
from app.models.savings import SavingsPlan
from app.models.investment import InvestmentPortfolio, Asset, AssetType
from app.models.news import News
from app.models.user import User

# Alembic Config object
config = context.config

# Load logging configuration
if config.config_file_name:
    fileConfig(config.config_file_name)

# Set the database URL dynamically from settings
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)

# Define target metadata
target_metadata = Base.metadata

def run_migrations_offline():
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(url=url, target_metadata=target_metadata, literal_binds=True, compare_type=True)

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online():
    """Run migrations in 'online' mode."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
