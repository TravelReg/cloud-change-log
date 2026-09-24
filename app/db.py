import os
from datetime import datetime, timezone

from sqlalchemy.engine import URL
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


if os.getenv("DB_HOST"):
    database_url = URL.create(
        "postgresql+psycopg",
        username=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        host=os.environ["DB_HOST"],
        port=int(os.getenv("DB_PORT", "5432")),
        database=os.environ["DB_NAME"],
    )
else:
    database_url = os.getenv("DATABASE_URL", "sqlite:///./changes.db")

connect_args = (
    {"check_same_thread": False}
    if isinstance(database_url, str) and database_url.startswith("sqlite")
    else {}
)

engine = create_engine(database_url, connect_args=connect_args)


def create_tables():
    SQLModel.metadata.create_all(engine)