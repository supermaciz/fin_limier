## Context

FinLimier is a Phoenix application with the conventional split between `lib/fin_limier` and `lib/fin_limier_web`. The project already has early core modules in English, including `FinLimier.Core.JobOffer` as an `embedded_schema`.

This change introduces the first useful job-search slice: scheduled job discovery, structured extraction, persistence, and review. The design keeps FinLimier as a single Phoenix app rather than an umbrella, and treats LiveView and Oban as driving adapters that call use cases.

## Goals / Non-Goals

**Goals:**

- Fetch job offers through a source port, with France Travail as the first production adapter.
- Parse raw offers into `FinLimier.Core.JobOffer` through an LLM extraction port.
- Persist normalized offers with source metadata and deduplicate by source identity.
- Run discovery through an Oban worker and expose a minimal LiveView review screen.
- Keep code names, modules, and domain vocabulary in English.

**Non-Goals:**

- No direct scraping of WTTJ, LinkedIn, or other job boards.
- No IMAP alert ingestion in this change.
- No free-form cover letter/CV generation in this change.
- No interview preparation or feedback-loop scoring in this change.
- No Gleam, umbrella split, `gen_statem`, or agent framework.

## Decisions

### Keep the standard Phoenix app split

Use `lib/fin_limier` for core, use cases, ports, driven adapters, workers, and persistence. Use `lib/fin_limier_web` for the LiveView review screen.

Alternative considered: an umbrella or putting web modules under `FinLimier.Adapters.Web`. Rejected because this project has one deployment unit and Phoenix already provides a useful boundary: `FinLimier` must not depend on `FinLimierWeb`.

### Model this as a pipeline, not an autonomous agent

Discovery is a deterministic workflow:

```text
source -> raw offers -> extractor -> normalized offer -> persistence -> review UI
```

The system does not submit applications, send email, or act externally on behalf of the user.

### Use ports only around unstable I/O

Create behaviours for:

- `FinLimier.Ports.JobSource`
- `FinLimier.Ports.JobOfferExtractor`

Use cases call these behaviours. Concrete adapters live under `FinLimier.Adapters`.

Do not create driving ports for LiveView or Oban. They are delivery mechanisms that can call use cases directly.

### Keep `JobOffer` as an embedded schema for extraction

`FinLimier.Core.JobOffer` remains an `embedded_schema` because `instructor_lite` relies on Ecto schemas and changesets for structured extraction and validation retries.

This is not the persisted table schema. Add a persistence schema for stored offers under the persistence layer only if storage needs metadata that does not belong in the extracted core value.

### Persist source identity separately from extracted fields

Persisted records need source metadata:

- source name, for example `"france_travail"`
- source identifier from the external system
- source URL when available
- raw payload or enough raw text for debugging parse failures
- discovery timestamp

Deduplication uses a unique constraint on `{source, source_id}`.

### Use Oban for background discovery

Add Oban and configure a `FinLimier.Workers.DiscoverJobsWorker` queue. The worker calls `FinLimier.UseCases.DiscoverJobs`.

The worker should be manually invokable in tests and schedulable through Oban cron configuration.

### Use Req for France Travail HTTP

The France Travail adapter uses the existing `Req` dependency for HTTP. Token acquisition and caching should be isolated inside the adapter namespace so the use case remains independent from OAuth details.

## Risks / Trade-offs

- France Travail API credentials are unavailable during development -> provide a stub source adapter and keep tests independent from network/API credentials.
- LLM extraction is nondeterministic -> test use cases with a stub extractor and keep adapter-specific tests narrow.
- Source payloads may change -> keep raw source handling inside the adapter and persist source metadata for debugging.
- Duplicate detection may be incomplete if a source changes identifiers -> start with `{source, source_id}` and revisit only when real data shows a problem.
- Adding Oban introduces database-backed job tables -> use standard Oban migrations and keep the worker idempotent.

## Migration Plan

1. Add required dependencies and migrations.
2. Add ports, adapters, use cases, persistence schema, and worker.
3. Add a minimal LiveView route and screen for discovered offers.
4. Configure test stubs so the pipeline can be tested without external HTTP or LLM calls.
5. Run `mix precommit`.

Rollback is straightforward during MVP development: remove the route, worker configuration, adapters, use cases, and new database tables/migrations before release.

## Open Questions

- Which France Travail query defaults should be used first: `"Elixir"`, `"Erlang"`, `"backend"`, or a configurable list?
- Should raw payloads be persisted fully, or should the system store only raw text plus selected source metadata?
- Which LLM provider should be configured first for `instructor_lite`?
