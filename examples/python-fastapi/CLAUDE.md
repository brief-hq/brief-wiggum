# Brief AI Agent Setup - Python FastAPI Example

## Quick Start

- Run `/onboard` to load Brief context and report readiness
- Run `/onboard BRI-XXX` for specific Linear task with auto-generated todos
- All agents have access to Brief MCP for business context

## Context Loading Order

When `/onboard [BRI-XXX]` runs, context is loaded in this order:

### 1. Brief MCP (mcp__brief__brief_get_onboarding_context)
- **Product**: customers, service definition, competitive advantages
- **Personas**: top user types with needs and pain points
- **Strategic context**: 6-month goal, top metrics
- **Current work**: building, committed items
- **Recent decisions**: last 10 architectural/business decisions
- **Customer insights**: themes, sentiment

### 2. Linear Task Context (if BRI-XXX provided)
- **Issue**: title, description, acceptance criteria
- **Relations**: blocks, blocked by, related issues
- **Linked Brief documents** (if any)

### 3. Repository Rules
- Hard rules (never commit --amend, etc.)
- Code conventions
- Testing requirements

### 4. Domain Skills (.claude/skills/)
Adapted for Python where applicable.

## Hard Rules

### Blocked Operations

**Git History Modification (Destructive)**
- ❌ `git commit --amend`
- ❌ `git push --force` / `git push -f`
- ❌ `git rebase`
- ❌ `git reset`

**Git Work Destruction**
- ❌ `git checkout --ours` / `git checkout --theirs`
- ❌ `git checkout .`
- ❌ `git clean -f`

**Git Branch Operations**
- ❌ `git push` to main/master/production directly
- ❌ `git branch -D`

**Database Operations**
- ❌ `alembic downgrade base` - Destroys all migrations
- ❌ Direct `DROP TABLE` commands

**Required Behaviors**
- ✅ **ALWAYS**: Run lint, test, typecheck before commit/push
- ✅ **ALWAYS**: Use Brief MCP for context before architectural decisions
- ✅ **ALWAYS**: Check Brief decisions with guard_approach
- ❌ **NEVER**: commit/push without explicit approval (EXCEPTION: /prep)

## Architecture Overview

**MyFastAPIApp** uses the following stack:

- **Framework**: FastAPI 0.100+
- **Database**: PostgreSQL
- **ORM**: SQLAlchemy 2.0 (async)
- **Migrations**: Alembic
- **Auth**: Auth0 JWT validation
- **Testing**: pytest + pytest-asyncio
- **Linting**: ruff + black
- **Type checking**: mypy
- **Deployment**: Docker + Railway/AWS

### Commands

```bash
# Virtual environment
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows

# Dependencies
pip install -r requirements.txt
# or with poetry:
poetry install

# Development
uvicorn app.main:app --reload

# Testing
pytest
pytest --cov=app --cov-report=term-missing

# Linting
ruff check .
ruff format .
# or
black .
flake8 .

# Type checking
mypy app/
```

## Code Conventions

### API Routes

Location: `app/api/v1/[resource].py`

```python
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import get_current_user
from app.core.database import get_db
from app.models import Document, User

router = APIRouter(prefix="/documents", tags=["documents"])

class DocumentCreate(BaseModel):
    title: str
    content: str | None = None

class DocumentResponse(BaseModel):
    id: int
    title: str
    content: str | None
    org_id: str

    class Config:
        from_attributes = True

@router.post("/", response_model=DocumentResponse)
async def create_document(
    data: DocumentCreate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    document = Document(
        title=data.title,
        content=data.content,
        org_id=user.org_id,
        created_by=user.id,
    )
    db.add(document)
    await db.commit()
    await db.refresh(document)
    return document
```

### Database

- **ORM**: SQLAlchemy 2.0 with async support
- **Models**: `app/models/`
- **Migrations**: Alembic (`alembic/`)
- **Always filter by org_id** for multi-tenancy

```python
# app/models/document.py
from sqlalchemy import Column, Integer, String, ForeignKey
from app.core.database import Base

class Document(Base):
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True)
    title = Column(String, nullable=False)
    content = Column(String)
    org_id = Column(String, nullable=False, index=True)
    created_by = Column(Integer, ForeignKey("users.id"))
```

### Migrations

```bash
# Generate migration
alembic revision --autogenerate -m "Add documents table"

# Apply migrations
alembic upgrade head

# NEVER:
# - Hand-write migration files
# - Use alembic downgrade base
```

### Testing

- **Framework**: pytest with pytest-asyncio
- **Coverage**: 80% minimum
- **Location**: `tests/`

```python
# tests/api/test_documents.py
import pytest
from httpx import AsyncClient

from app.main import app

@pytest.mark.asyncio
async def test_create_document(client: AsyncClient, auth_headers: dict):
    response = await client.post(
        "/api/v1/documents/",
        json={"title": "Test Doc", "content": "Test content"},
        headers=auth_headers,
    )
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Doc"
```

### File Organization

```
app/
  api/
    v1/
      documents.py
      users.py
  core/
    config.py
    database.py
    auth.py
  models/
    document.py
    user.py
  schemas/
    document.py
    user.py
  main.py
tests/
  api/
    test_documents.py
  conftest.py
alembic/
  versions/
  env.py
requirements.txt
pyproject.toml
```

## Verification Commands (Modified for Python)

Update `.claude/hooks/verify-complete.sh`:

```bash
case $VERIFY_TYPE in
  tests)
    if ! pytest >/dev/null 2>&1; then
      result="fail"
    fi
    ;;
  lint)
    if ! ruff check . >/dev/null 2>&1; then
      result="fail"
    fi
    ;;
  typecheck)
    if ! mypy app/ >/dev/null 2>&1; then
      result="fail"
    fi
    ;;
  all|*)
    pytest && ruff check . && mypy app/
    ;;
esac
```

## Agent Capabilities

Same as Node.js version - context-loader, task-planner, implementation, pr-preparer, code-explorer.

## Brief MCP Integration

Same as Node.js version - product context, decisions, Linear sync.

## Workflow Commands

- `/onboard` - Load context
- `/onboard BRI-XXX` - Load Linear task
- `/todo-all` - Execute todos
- `/prep` - Validate and commit
- `/health` - Check environment

Note: Update `/prep` command verification steps for Python tooling.
