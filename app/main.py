import os
import secrets
from typing import Literal

from fastapi import Depends, FastAPI, HTTPException, Security
from fastapi.security import APIKeyHeader
from sqlmodel import Session, SQLModel, select

from app.db import Change, engine


app = FastAPI(title="Cloud Change Log")
admin_header = APIKeyHeader(name="X-Admin-Token", auto_error=False)


class NewChange(SQLModel):
    service: str
    environment: str
    summary: str


class StatusUpdate(SQLModel):
    status: Literal["planned", "in_progress", "completed", "rolled_back"]


def get_session():
    with Session(engine) as session:
        yield session


def require_admin(token: str | None = Security(admin_header)):
    expected = os.getenv("ADMIN_TOKEN")
    if not expected or token is None or not secrets.compare_digest(token, expected):
        raise HTTPException(status_code=401, detail="Invalid admin token")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/changes", response_model=list[Change], dependencies=[Depends(require_admin)])
def list_changes(session: Session = Depends(get_session)):
    return session.exec(select(Change).order_by(Change.id.desc())).all()


@app.post("/changes", response_model=Change, status_code=201,
          dependencies=[Depends(require_admin)])
def record_change(data: NewChange, session: Session = Depends(get_session)):
    change = Change.model_validate(data)
    session.add(change)
    session.commit()
    session.refresh(change)
    return change


@app.patch("/changes/{change_id}", response_model=Change,
           dependencies=[Depends(require_admin)])
def update_status(
    change_id: int,
    data: StatusUpdate,
    session: Session = Depends(get_session),
):
    change = session.get(Change, change_id)
    if change is None:
        raise HTTPException(status_code=404, detail="Change not found")

    change.status = data.status
    session.add(change)
    session.commit()
    session.refresh(change)
    return change