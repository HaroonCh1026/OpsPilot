# OpsPilot Architecture

This document distinguishes the code that exists today from the intended
system architecture. The repository is an early foundation; planned
capabilities below are not claims of implemented behavior.

## Current implementation

- **Frontend:** `apps/web` is a Next.js App Router application with the
  scaffolded starter page. It does not currently call the Rails API.
- **Rails API:** `services/api` is an API-only Rails application. It exposes
  the Rails `/up` health endpoint and has an `Organization` model with required
  `name` and `slug` validations. The database enforces a unique index on the
  organization slug. There are not yet authentication, membership, or
  organization-management endpoints.
- **Database:** `compose.yml` defines PostgreSQL 16 and uses the existing
  external `opspilot_pgdata` volume. The current Rails schema contains the
  organizations table and PostgreSQL's `plpgsql` extension only; pgvector,
  document tables, and tenant-scoped content are not yet present.
- **Background work and storage:** Rails includes Solid Queue, Solid Cache,
  and Solid Cable dependencies and production adapter configuration.
  Active Storage is configured to use disk in production, but document upload
  and processing behavior is not implemented. Redis and Sidekiq are not
  configured as application dependencies.
- **AI service:** `services/ai` is a FastAPI application with `GET /health`
  returning `{"status": "ok"}`. Its current environment-backed setting names
  the application; document processing, retrieval, generation, and Rails
  integration are not implemented.

## Intended request and data boundaries

When the product features are built, the expected flow is:

1. The Next.js frontend sends user requests to Rails.
2. Rails authenticates users, authorizes organization access, and remains the
   authority for business rules and tenant-scoped data.
3. Rails stores product data in PostgreSQL and dispatches background work
   through the configured job system.
4. Rails invokes the AI service for authorized processing. The AI service is
   an internal processing component, not an authorization authority.
5. Search and answer generation use retrieved evidence and return citations
   through Rails to the frontend.

This flow is a target, not a description of currently connected services.

## Security boundaries

- Implement identity and authorization in Rails; do not trust organization
  identifiers supplied directly by a browser.
- Enforce tenant scope in every organization-owned query and background job.
  Membership and tenant-isolation behavior remain to be implemented and
  tested.
- Keep original documents in private storage when document handling is added.
- Do not write secrets or document contents to application logs.
- Keep local credentials in ignored environment files and provide placeholders
  only in tracked example files.
- The Rails master key is currently tracked in `services/api/config/master.key`
  and exists in pushed history. Rails deployment configuration passes
  `RAILS_MASTER_KEY`, and the Kamal secrets helper obtains it from that file.
  Rails also resolves `secret_key_base` from encrypted credentials during
  application initialization; `.env` does not replace the master key. Treat
  the encrypted credentials and key as exposed; coordinate key rotation and
  credential/deployment updates before removing the key from history.

## Development strategy

Build and validate services locally and incrementally. Add integrations only
after their authorization, tenant-isolation, reliability, and security
requirements are defined and tested.
