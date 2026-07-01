## Why

FinLimier currently assumes Postgres for discovered job storage: use cases call
`FinLimier.Repo` directly and the application always starts the Ecto repo. We
now want the app to be usable without Postgres, starting with an ETS-backed
storage mode and leaving room for DETS later.

## What Changes

- Introduce a `JobOfferStore` port for discovered job offer persistence and
  listing.
- Rename the storage namespace from `Persistence` to `Storage`, because not all
  backends are durable.
- Move the Ecto repo and Postgres schemas under a `Storage.Postgres` namespace.
- Add a Postgres store adapter that preserves the current persisted behavior.
- Add an ETS store adapter for local, Postgres-free discovered job storage.
- Make job discovery and review use cases depend on the configured store
  instead of calling the Ecto repo directly.
- Update configuration, application startup, tests, and architecture docs to
  reflect configurable storage.

## Capabilities

### New Capabilities

- `job-offer-storage`: configurable storage for discovered job offers, including
  Postgres and ETS backends.

### Modified Capabilities

- `job-discovery`: discovery must persist, deduplicate, and list offers through
  the configured job offer store rather than assuming Postgres.

## Impact

- Affects `FinLimier.UseCases.DiscoverJobs` and
  `FinLimier.UseCases.ListDiscoveredJobs`.
- Adds a new port under `FinLimier.Ports`.
- Replaces `FinLimier.Persistence` with `FinLimier.Storage` namespaces.
- Renames `FinLimier.Repo` to `FinLimier.Storage.Postgres.Repo`.
- Updates Ecto, Oban, sandbox, release, and test configuration references to
  the moved repo.
- Adds ETS runtime supervision/configuration for the local storage backend.
- Supersedes the accepted architecture note that allowed direct repo access in
  use cases.
