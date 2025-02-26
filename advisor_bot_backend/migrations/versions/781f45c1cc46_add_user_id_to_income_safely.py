"""Add user_id to income safely

Revision ID: 781f45c1cc46
Revises: 443a85cd8458
Create Date: 2025-02-26 14:43:39.449652

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '781f45c1cc46'
down_revision: Union[str, None] = '443a85cd8458'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ✅ Step 1: Add the column as NULLABLE first
    op.add_column('income', sa.Column('user_id', sa.Integer(), nullable=True))
    
    # ✅ Step 2: Assign a default user_id (Assuming `1` is a valid user)
    op.execute("UPDATE income SET user_id = 1 WHERE user_id IS NULL")

    # ✅ Step 3: Set the column to NOT NULL
    op.alter_column('income', 'user_id', existing_type=sa.Integer(), nullable=False)

    # ✅ Step 4: Create a foreign key constraint for `income.user_id`
    op.create_foreign_key('fk_income_user', 'income', 'users', ['user_id'], ['id'])

    # 🏦 Apply the same logic for `investment_portfolios`
    op.add_column('investment_portfolios', sa.Column('user_id', sa.Integer(), nullable=True))
    op.execute("UPDATE investment_portfolios SET user_id = 1 WHERE user_id IS NULL")
    op.alter_column('investment_portfolios', 'user_id', existing_type=sa.Integer(), nullable=False)
    op.create_foreign_key('fk_investment_portfolios_user', 'investment_portfolios', 'users', ['user_id'], ['id'])

    # 📰 Fix `news` table migration
    op.add_column('news', sa.Column('user_id', sa.Integer(), nullable=True))
    op.execute("UPDATE news SET user_id = 1 WHERE user_id IS NULL")
    op.alter_column('news', 'user_id', existing_type=sa.Integer(), nullable=False)
    op.create_foreign_key('fk_news_user', 'news', 'users', ['user_id'], ['id'])

    # 🗓️ Add created_at columns where necessary
    op.add_column('news', sa.Column('created_at', sa.DateTime(), nullable=True))
    op.add_column('savings_plans', sa.Column('created_at', sa.DateTime(), nullable=True))

    # 🔻 Drop old columns no longer needed
    op.drop_column('news', 'content')
    op.drop_column('news', 'source')
    op.drop_column('news', 'title')


def downgrade() -> None:
    # Reverse the changes in order
    op.drop_constraint('fk_news_user', 'news', type_='foreignkey')
    op.drop_column('news', 'user_id')
    op.drop_column('news', 'created_at')

    op.drop_constraint('fk_income_user', 'income', type_='foreignkey')
    op.drop_column('income', 'user_id')

    op.drop_constraint('fk_investment_portfolios_user', 'investment_portfolios', type_='foreignkey')
    op.drop_column('investment_portfolios', 'user_id')

    op.drop_column('savings_plans', 'created_at')

    # Restore dropped columns
    op.add_column('news', sa.Column('title', sa.VARCHAR(length=255), nullable=False))
    op.add_column('news', sa.Column('source', sa.VARCHAR(length=255), nullable=False))
    op.add_column('news', sa.Column('content', sa.TEXT(), nullable=False))
