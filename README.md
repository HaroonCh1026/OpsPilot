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

The current foundation includes:

- **Frontend:** Next.js, React, TypeScript, Tailwind CSS
- **Backend API:** API-only Ruby on Rails 8.1
- **Database:** PostgreSQL 16; the current schema does not yet include pgvector
- **AI Service:** Python and FastAPI
- **Background adapters:** Rails Solid Queue, Solid Cache, and Solid Cable
  dependencies/configuration are present; product jobs are not implemented.
- **Checks:** Rails Minitest, Python pytest, and frontend ESLint/production
  build. Frontend unit, browser, and RAG evaluation suites are not present yet.

Vector search, document ingestion, retrieval-augmented generation, and
organization-aware product behavior remain planned work. Redis and Sidekiq
are not currently configured as application dependencies.

## Repository Structure

- `apps/web` — Next.js frontend
- `services/api` — Rails API
- `services/ai` — Python AI service
- `packages` — Reserved for future shared API contracts
- `infra` — Reserved for future infrastructure; the current PostgreSQL Compose
  configuration is at the repository root
- `tests` — Reserved for future end-to-end, load, and AI evaluation suites
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

Rails encrypted credentials are separate from `.env`: Rails uses
`services/api/config/master.key` to derive `secret_key_base` during boot. That
key is currently tracked in pushed history and must be treated as exposed;
see the [week-one progress note](docs/progress-week-1.md). Do not use `.env`
values as a substitute for the Rails master key.

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

Run the Rails CI security and style checks:

```powershell
bundle exec brakeman --no-pager
bundle exec bundler-audit
bundle exec rubocop -f github
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

## Continuous Integration

GitHub Actions runs on pushes to `main` and pull requests targeting `main`.
Independent jobs test Rails against an isolated PostgreSQL 16 container,
scan and lint the Rails API, run the AI service's pytest suite, and lint/build
the frontend. Run the corresponding commands locally using the service
instructions above; CI's test-only database credentials are not used by local
development.

## Project Status

The repository contains the initial frontend, Rails, and FastAPI foundations,
plus local development instructions and a CI workflow. Identity,
memberships, tenant-scoped APIs, document ingestion, and retrieval are not
implemented. The expanded CI workflow has not yet been verified by a GitHub
Actions run; see [the week-one progress note](docs/progress-week-1.md) for
evidence and current blockers.