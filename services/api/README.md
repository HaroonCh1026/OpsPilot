# OpsPilot Rails API

## Prerequisites

- Ruby 4.0.5 (see `.ruby-version`)
- Bundler
- PostgreSQL 16 reachable from this machine

For the two-laptop database setup and frontend/AI service commands, see the
repository [development guide](../../README.md#local-development).

## Configure and run

From `services\api`, create `.env` from the example if it does not already
exist:

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
```

Set `OPSPILOT_DB_HOST` to the PostgreSQL server address and
`OPSPILOT_DB_PASSWORD` to the local database password. The Rails development
and test environments load this file with `dotenv-rails`.

Install gems and start the API:

```powershell
bundle install
ruby .\bin\rails server -p 3001
```

The server listens at `http://localhost:3001`; `GET /up` is the Rails health
check. Port 3001 avoids conflicting with the frontend's default port 3000.

## Tests

With both development and test PostgreSQL databases reachable, run:

```powershell
ruby .\bin\rails test
```

For one test file, pass its path, for example:

```powershell
ruby .\bin\rails test test\controllers\health_controller_test.rb
```

Avoid `bin/setup` for routine startup: it runs `db:prepare` and clears Rails
logs and temporary files. Do not use `db:reset` to troubleshoot connection
problems.
