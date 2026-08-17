"""add session analysis fields

Revision ID: e8a1c5d3f7b2
Revises: d4e7f2a91b3c
Create Date: 2026-08-16 00:00:00.000000
"""
from typing import Sequence, Union
import sqlalchemy as sa
from alembic import op

revision: str = "e8a1c5d3f7b2"
down_revision: Union[str, None] = "d4e7f2a91b3c"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("sessions", sa.Column("transcript", sa.Text(), nullable=True))
    op.add_column("sessions", sa.Column("filler_word_count", sa.Integer(), nullable=True))
    op.add_column("sessions", sa.Column("words_per_minute", sa.Integer(), nullable=True))
    op.add_column("sessions", sa.Column("coherence_score", sa.Integer(), nullable=True))
    op.add_column("sessions", sa.Column("grammar_score", sa.Integer(), nullable=True))
    op.add_column("sessions", sa.Column("content_accuracy_score", sa.Integer(), nullable=True))
    op.add_column("sessions", sa.Column("feedback_summary", sa.Text(), nullable=True))
    op.add_column("sessions", sa.Column("analyzed_at", sa.DateTime(), nullable=True))


def downgrade() -> None:
    op.drop_column("sessions", "analyzed_at")
    op.drop_column("sessions", "feedback_summary")
    op.drop_column("sessions", "content_accuracy_score")
    op.drop_column("sessions", "grammar_score")
    op.drop_column("sessions", "coherence_score")
    op.drop_column("sessions", "words_per_minute")
    op.drop_column("sessions", "filler_word_count")
    op.drop_column("sessions", "transcript")
