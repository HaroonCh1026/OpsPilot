# OpsPilot Progress — Days 1–7

## Completed foundation work

- **Days 1–2:** Scaffolded the Next.js frontend and API-only Rails service,
  configured local PostgreSQL 16 with the external `opspilot_pgdata` volume,
  added the Organization table/model and validation tests, and added a request
  test for the existing Rails `/up` health endpoint.
- **Day 3:** Added the FastAPI AI service, `/health` endpoint, environment-backed
  application-name setting, pytest coverage, dependency manifests, and local
  startup instructions.
- **Day 4:** Added placeholder-only environment templates and documented
  service configuration without checking in local credentials.
- **Day 5:** Documented Windows PowerShell development, test, and two-laptop
  PostgreSQL workflows.
- **Day 6:** Added the root GitHub Actions workflow for Rails, Python, and
  frontend checks. Corrected the Rails Gemfile spacing found by RuboCop.
- **Day 7:** Reviewed the current architecture and repository safety. No
  roadmap file or specific Day 7 milestone was found, so no additional product
  milestone was inferred.

## Verification evidence

Local checks recorded during this work:

- Rails tests previously passed: 5 runs, 11 assertions, 0 failures, 0 errors.
  The current configured PostgreSQL host is unreachable, so the Rails suite
  was not rerun in this review.
- Rails RuboCop passed after the Gemfile formatting correction.
- Brakeman completed with 0 security warnings.
- Bundler Audit completed with no reported vulnerable dependencies.
- Python pytest: 2 passed; the installed Starlette TestClient emitted one
  deprecation warning about its `httpx` integration.
- Frontend ESLint and production build passed.
- The workflow YAML and its local job wiring were structurally validated.
- GitHub Actions run `40415740799` succeeded for commit `0464b91`; that run
  contained only the frontend checks. The expanded Rails and Python jobs have
  not been verified by a GitHub Actions run.

## Review findings and blockers

- No 84-day roadmap or Day 7 acceptance criteria are present in tracked
  repository documentation.
- `services/api/config/master.key` is tracked and matches Rails' master-key
  format and is present in pushed history. Its contents are intentionally not
  reproduced here. `config/deploy.yml` injects `RAILS_MASTER_KEY`, and the
  tracked Kamal helper sources it from the key file. The `.kamal/secrets`
  entry is a command reference, not a literal key. No application-specific
  credential reads were found in active configuration (the visible examples
  are commented out), but Rails itself resolves `secret_key_base` from the
  encrypted credentials during initialization. A test-environment boot with
  an intentionally invalid key failed during credential authentication; a
  boot with the configured key succeeded without requesting a database query.
  Thus `.env` does not replace the master key, and the current dev/test boot
  depends on a valid key. Treat the key and encrypted credentials as exposed.
  Coordinate key rotation, encrypted-credential handling, and deployment
  secret updates before removing the key from history; do not delete the local
  key or rewrite history as routine cleanup.
- Rails log and Bootsnap cache files are tracked (1,553 tracked paths under
  `tmp/cache` and 2 under `log` were found during review); additional generated
  cache files and a test log are present in the worktree. They were preserved.
  The ignore rules now cover nested Rails logs, tmp files, storage, Rails
  master-key paths, and local database files. Ignore rules do not untrack
  files already in Git. The repository has no tracked local database dump,
  virtual-environment, Node dependency, or build-output files.
- Python requirements use version ranges and there is no committed Python
  lockfile. Python dependency installation is therefore not fully
  reproducible; pip caching is disabled in CI until a lockfile is adopted.
- The expanded CI workflow has not run on GitHub, and local Rails integration
  tests are blocked by PostgreSQL being unreachable at the configured host.
- The requested Day 7 clean-worktree condition is not met: this review
  preserves existing uncommitted workflow/documentation edits, tracked cache
  changes, and generated artifacts.
- Branch `main` tracks `origin/main` with no ahead/behind commits. No changes
  are staged. The current uncommitted diff includes the CI workflow, ignore
  rules, README, architecture note, Rails Gemfile formatting, and a tracked
  Bootsnap cache change; the week-one progress note is new.

## Next priorities

The repository does not establish a roadmap order. The following candidate
priorities reflect the requested identity, organization, membership, and
tenant-isolation focus; they are recommendations, not existing Day 8
acceptance criteria:

1. Define identity, authentication, and authorization requirements.
2. Design organization membership and role semantics.
3. Add authorization-aware organization APIs and tenant-scoped associations.
4. Add cross-tenant access-denial tests before implementing document retrieval.
5. Record an explicit roadmap with acceptance criteria and local/CI test
   evidence for each milestone.
