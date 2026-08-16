"""add preferred area and daily topics

Revision ID: d4e7f2a91b3c
Revises: a1b2c3d4e5f6
Create Date: 2026-08-16 00:00:00.000000
"""
from typing import Sequence, Union
import sqlalchemy as sa
from alembic import op

revision: str = "d4e7f2a91b3c"
down_revision: Union[str, None] = "a1b2c3d4e5f6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("users", sa.Column("preferred_area_id", sa.String(36), nullable=True))
    op.create_foreign_key(
        "fk_users_preferred_area_id_areas",
        "users",
        "areas",
        ["preferred_area_id"],
        ["id"],
        ondelete="SET NULL",
    )
    op.create_index("ix_users_preferred_area_id", "users", ["preferred_area_id"])

    op.create_table(
        "daily_topics",
        sa.Column("id", sa.String(36), nullable=False),
        sa.Column("user_id", sa.String(36), nullable=False),
        sa.Column("date", sa.Date(), nullable=False),
        sa.Column("area_id", sa.String(36), nullable=False),
        sa.Column("area_name", sa.String(100), nullable=False),
        sa.Column("topic_name", sa.String(200), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "date"),
    )
    op.create_index("ix_daily_topics_user_id", "daily_topics", ["user_id"])


def downgrade() -> None:
    op.drop_index("ix_daily_topics_user_id", table_name="daily_topics")
    op.drop_table("daily_topics")

    op.drop_index("ix_users_preferred_area_id", table_name="users")
    op.drop_constraint("fk_users_preferred_area_id_areas", "users", type_="foreignkey")
    op.drop_column("users", "preferred_area_id")
