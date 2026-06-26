## Why

FinLimier needs a first usable slice that finds job offers without manual effort, normalizes them, and makes them reviewable in the Phoenix application. This creates value that a chat-only workflow cannot provide: scheduled discovery, persistence, deduplication, and a stable foundation for later scoring, document generation, and interview feedback loops.

## What Changes

- Add a job discovery pipeline that can fetch raw job offers from external sources on demand or from a scheduled worker.
- Add structured job offer extraction so raw source payloads can become normalized `FinLimier.Core.JobOffer` values.
- Persist discovered offers with enough source metadata to deduplicate future runs.
- Expose discovered offers in a minimal LiveView review screen.
- Keep architecture aligned with `FinLimier` conventions: English module/function names, `lib/fin_limier` for core/use cases/adapters/workers, and `lib/fin_limier_web` for the web driving adapter.
- Defer IMAP alerts, free-form document generation, interview preparation, and feedback-based scoring to later changes.

## Capabilities

### New Capabilities

- `job-discovery`: Fetching, parsing, deduplicating, storing, and reviewing discovered job offers.

### Modified Capabilities

None.

## Impact

- Affected application code: `lib/fin_limier/core`, `lib/fin_limier/use_cases`, `lib/fin_limier/ports`, `lib/fin_limier/adapters`, `lib/fin_limier/workers`, and `lib/fin_limier_web/live`.
- Affected persistence: new Ecto migration and schema/table for persisted job offers.
- New dependencies likely required: Oban for scheduled/background work and `instructor_lite` for structured LLM extraction.
- Existing dependency to reuse: `Req` for HTTP calls.
- External systems: France Travail job offers API for the first source; LLM provider configured through `instructor_lite`.
