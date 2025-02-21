"""Add users table

Revision ID: 1f4f77a8e15f
Revises: 610164325290
Create Date: 2025-02-15 23:27:50.833400
"""

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '1f4f77a8e15f'
down_revision = '610164325290'
branch_labels = None
depends_on = None


def upgrade():
    """Create users table"""
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("email", sa.String(150), unique=True, nullable=False),
        sa.Column("hashed_password", sa.String(255), nullable=False),
        sa.Column("created_at", sa.DateTime(), server_default=sa.func.now()),
    )


def downgrade():
    """Drop users table"""
    op.drop_table("users")
