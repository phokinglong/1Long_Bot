import sys
import os
from logging.config import fileConfig

from sqlalchemy import engine_from_config, pool
from alembic import context

# Ensure Alembic finds your models by adding the project root
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

# Import database and models
from config.database import Base
from app.models.agents import Agent
from app.models.knowledge_bases import KnowledgeBase
from app.models.features import Feature

# Load Alembic config
config = context.config

# Apply logging configuration
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Set target metadata for autogeneration
target_metadata = Base.metadata

def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
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
