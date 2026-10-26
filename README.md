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

## Project Status

Initial repository setup. Application services and automated tests will be added incrementally.