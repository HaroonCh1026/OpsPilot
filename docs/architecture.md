# OpsPilot Architecture

## Request Flow

1. The user interacts with the Next.js frontend.
2. The Rails API authenticates the user and authorizes organization access.
3. Rails manages documents, conversations, permissions, and business rules.
4. Redis and Sidekiq handle background document-processing jobs.
5. The Python AI service processes documents and performs retrieval and generation.
6. PostgreSQL stores application data, full-text indexes, and vector embeddings.
7. The API returns answers with citations to the frontend.

## Security Boundaries

- Rails is the authority for authentication and authorization.
- The AI service must not trust organization IDs supplied directly by the browser.
- Retrieval must enforce organization-level isolation.
- Original documents must use private storage.
- Secrets and document contents must not be written to application logs.

## Development Strategy

Develop locally first. Add components incrementally, verify each integration, and deploy only after security and reliability checks.