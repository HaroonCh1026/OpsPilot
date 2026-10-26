# OpsPilot

OpsPilot is an AI-powered knowledge and operations platform for software engineering teams. It helps engineers find answers from internal technical documents with relevant evidence and citations.

## Goals

- Provide secure organization and workspace management.
- Upload and manage internal engineering documents.
- Process documents through a reliable background ingestion pipeline.
- Search documents using PostgreSQL full-text search and vector similarity.
- Generate AI answers grounded in retrieved document passages.
- Include citations so users can verify answers.
- Enforce strict organization-level data isolation.
- Measure retrieval quality, reliability, performance, and security.

## Technology Stack

- **Frontend:** Next.js, React, TypeScript, Tailwind CSS
- **Backend API:** Ruby on Rails
- **Database:** PostgreSQL with pgvector
- **Background Jobs:** Redis and Sidekiq
- **AI Service:** Python and FastAPI
- **Testing:** RSpec, pytest, frontend tests, Playwright, and RAG evaluation

## Repository Structure

- `apps/web` — Next.js frontend
- `services/api` — Rails API
- `services/ai` — Python AI service
- `packages/contracts` — Shared API contracts
- `infra` — Infrastructure and Docker configuration
- `tests` — End-to-end, load, and AI evaluation tests
- `docs` — Architecture, security, and technical decisions

## Development Principles

- Build and test locally before deploying.
- Keep secrets out of source control.
- Enforce authorization on every protected resource.
- Prevent cross-organization data access.
- Make background jobs safe to retry.
- Ground AI responses in retrieved evidence.
- Test failure cases as well as successful workflows.
- Document measured results honestly.

## Local Development

### Prerequisites

- Windows with PowerShell and Docker Desktop (Docker Compose v2)
- Node.js 24 and npm for the frontend
- Ruby 4.0.5 and Bundler for the Rails API
- Python 3.13 for the AI service
- PostgreSQL 16, provided by the existing Compose service

Keep local credentials in ignored `.env` files. The checked-in `.env.example`
files contain placeholders only.

### Two-Laptop PostgreSQL Setup

Choose one laptop to host PostgreSQL and the other as the main development
laptop. Both should be on a trusted network.

**Database laptop (run from the repository root):**

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
```

Edit `.env` and replace `OPSPILOT_DB_PASSWORD` with a local-only password.
Start and check the existing PostgreSQL service:

```powershell
docker compose up -d postgres
docker compose ps postgres
docker compose exec postgres pg_isready -U opspilot -d opspilot_development
```

This uses the existing `opspilot_pgdata` volume; do not remove or recreate it.
Find the database laptop's LAN address with `ipconfig`. Allow inbound TCP port
5432 through its firewall only for the trusted development network.

**Main development laptop:**

Create `services\api\.env` from the sample if it does not already exist:

```powershell
if (-not (Test-Path services\api\.env)) {
    Copy-Item services\api\.env.example services\api\.env
}
```

Set `OPSPILOT_DB_HOST` in that file to the database laptop's LAN address. Set
`OPSPILOT_DB_PASSWORD` to the same local-only password as on the database
laptop. Keep port 5432 and username `opspilot` aligned with Compose. Check
reachability from PowerShell:

```powershell
Test-NetConnection -ComputerName "192.168.1.25" -Port 5432
```

Replace the example address with the database laptop's LAN address.
Rails development and test load `services/api/.env` via `dotenv-rails`. The
root `.env` is for Compose on the database laptop, not a substitute for the
Rails service `.env`. For production, provide `OPSPILOT_DB_HOST`,
`OPSPILOT_DB_USERNAME`, and `OPSPILOT_DB_PASSWORD` through the process
environment.

### Frontend

From `apps\web`, install the locked dependencies, start the development server,
and run the available checks:

```powershell
npm.cmd ci
npm.cmd run dev
npm.cmd run lint
npm.cmd run build
```

The development server is available at `http://localhost:3000`. There is no
frontend unit-test script in `apps/web/package.json` yet.

### Rails API

From `services\api`, install gems and start the API:

```powershell
bundle install
ruby .\bin\rails server -p 3001
```

Run the Rails tests from the same directory:

```powershell
ruby .\bin\rails test
```

The API is available at `http://localhost:3001`; Rails exposes its health
check at `http://localhost:3001/up`. Port 3001 avoids conflicting with the
frontend's default port 3000. Both the development and test databases must be
reachable on the configured PostgreSQL host before running the suite. Prefer
`bundle install` for routine dependency setup: `bin/setup` also prepares the
database and clears Rails logs and temporary files.

### FastAPI AI Service

From `services\ai`, create a virtual environment and install the development
dependencies:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
```

Optionally copy `services\ai\.env.example` to `services\ai\.env` and set
`OPSPILOT_AI_*` values. Start the development server and run its tests from
`services\ai`:

```powershell
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload
.\.venv\Scripts\python.exe -m pytest
```

The health endpoint is available at `http://localhost:8000/health`. No AI
credentials are required by the current service.

### Troubleshooting

- If Compose cannot start PostgreSQL, confirm Docker Desktop is running and
  inspect `docker compose ps postgres` and `docker compose logs postgres`.
- If Rails cannot connect, confirm `OPSPILOT_DB_HOST`, port, username, and
  password in `services/api/.env`; then check `Test-NetConnection` and the
  database laptop's firewall. Do not run `db:reset` to troubleshoot.
- If Rails reports that a database is unavailable, check the configured
  development/test database names and server reachability before changing any
  database state.
- If PowerShell cannot find a dependency, confirm the expected runtime is on
  `PATH` and install dependencies from the service's documented directory.
- If a service port is occupied, stop the other process or use that service's
  documented server options to choose another port.

## Project Status

Initial repository setup. Application services and automated tests will be added incrementally.