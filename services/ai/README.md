# OpsPilot AI Service

The AI service is a FastAPI application. Configuration uses `OPSPILOT_AI_`
environment variables; `OPSPILOT_AI_APP_NAME` sets the application name shown
in the API documentation. When launched from `services\ai`, values can also
come from its local `.env` file. No credentials are currently required.

## Prerequisites and local development

Use Python 3.13. From `services\ai`, create a virtual environment and install
the development dependencies:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
```

Optionally create `.env` from the sample if it does not already exist:

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
```

Alternatively, set configuration directly in PowerShell. Start the
development server from this directory:

```powershell
$env:OPSPILOT_AI_APP_NAME = "OpsPilot AI Service"
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload
```

The health endpoint is available at `http://127.0.0.1:8000/health`.

## Tests

Run the tests from `services\ai`:

```powershell
.\.venv\Scripts\python.exe -m pytest
```

For the PostgreSQL two-laptop setup and commands for other services, see the
repository [development guide](../../README.md#local-development).

## Troubleshooting

- If imports fail, check that the virtual environment exists and install
  `requirements-dev.txt` using its Python executable.
- If a `.env` setting is not loaded, confirm the current directory is
  `services\ai`; the configured `.env` path is relative to the working
  directory. Process environment variables take precedence.
- If port 8000 is occupied, stop the conflicting process or pass a different
  port to Uvicorn, such as `--port 8001`.
