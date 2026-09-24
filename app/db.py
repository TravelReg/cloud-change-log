import os
from datetime import datetime, timezone

from sqlmodel import Field, SQLModel, create_engine


class Change(SQLModel, table=True):
    __tablename__ = "changes"

    id: int | None = Field(default=None, primary_key=True)
    service: str
    environment: str
    summary: str
    status: str = "planned"
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc)
    )


database_url = os.getenv("DATABASE_URL", "sqlite:///./changes.db")
connect_args = (
    {"check_same_thread": False}
    if database_url.startswith("sqlite")
    else {}
)
engine = create_engine(database_url, connect_args=connect_args)


def create_tables():
    SQLModel.metadata.create_all(engine)