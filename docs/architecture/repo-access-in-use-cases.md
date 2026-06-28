# Repo access in use cases

Status: accepted — 2026-06-28
Scope: `FinLimier.UseCases.*`

## Decision

Use cases (`FinLimier.UseCases.DiscoverJobs`, `FinLimier.UseCases.ListDiscoveredJobs`)
call `FinLimier.Repo` directly. We do not introduce a `JobOfferStore` port for
persistence.

## Why

- The project principle (see the `add-job-discovery-pipeline` design) is:
  "ports only around unstable I/O". The existing ports cover the unpredictable
  dependencies: `JobSource` (external HTTP) and `JobOfferExtractor`
  (non-deterministic LLM).
- The database is not an unstable dependency. Ecto/Repo is already an
  abstraction layer (the Postgres adapter is swappable); re-abstracting it would
  mean abstracting an abstraction.
- It is the idiomatic Phoenix/Ecto approach: contexts call `Repo` directly.
  Tests already use a real database through the Ecto sandbox (`DataCase`), which
  is fast and isolated — no in-memory stub needed.

## When to reconsider

Introducing a persistence port (or, at minimum, extracting the
persistence/dedup logic into a context module such as `FinLimier.JobOffers`)
would become justified if:

- we want to test the use cases without a database;
- persistence may move off Ecto (another store, an API);
- we want a strict domain boundary with no Ecto details in the use cases.

None of these hold today.

## Consequences

- `DiscoverJobs` mixes two levels: calls through ports (source/extractor) and a
  concrete call (`Repo`). This is intentional.
- If this asymmetry ever becomes a problem, the clean way out is not a port but
  a `FinLimier.JobOffers` context module that the use case would call.
