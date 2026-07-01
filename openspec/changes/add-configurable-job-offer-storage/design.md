## Context

The job discovery pipeline currently treats Postgres as an implementation
detail: `DiscoverJobs` checks duplicates with `FinLimier.Repo`, inserts
`FinLimier.Persistence.DiscoveredJobOffer`, and `ListDiscoveredJobs` reads the
same schema directly. That matched the earlier decision to avoid a persistence
port while Postgres was the only expected storage backend.

The new requirement is different. FinLimier should be usable without Postgres,
starting with a volatile ETS store and keeping the door open for a DETS-backed
local store later. That makes job offer storage a runtime-selectable backend,
not a fixed implementation detail.

## Goals / Non-Goals

**Goals:**

- Introduce a `JobOfferStore` port for discovered offer storage operations.
- Keep the existing Postgres behavior available through a Postgres storage
  adapter.
- Add an ETS storage adapter that lets discovery and review run without
  Postgres.
- Rename `Persistence` to `Storage`, because the namespace must cover both
  durable and volatile backends.
- Move `FinLimier.Repo` to `FinLimier.Storage.Postgres.Repo` so the repo belongs
  to the Postgres storage adapter.
- Update config, supervision, Boundary declarations, docs, and tests to use the
  configured store.

**Non-Goals:**

- Do not add DETS in this change.
- Do not replace Oban with a Postgres-free scheduler in this change.
- Do not migrate existing database tables or alter the stored offer columns.
- Do not introduce a generic repository abstraction for all future domain data.

## Decisions

### Use a `JobOfferStore` port for discovered job offers

Add `FinLimier.Ports.JobOfferStore` as the use case dependency for storing and
listing discovered offers. The port should expose domain-level operations, not
low-level query primitives. A likely shape is:

- `insert_new(raw_offer, job_offer)` returning `{:ok, stored_offer}`,
  `{:error, :duplicate}`, or `{:error, reason}`
- `list_discovered(opts)` returning stored offers ordered newest-first

This keeps deduplication inside the store adapter, where atomicity differs by
backend. Postgres can rely on a unique index and ETS can use a table operation
keyed by `{source, source_id}`.

Alternative considered: keep duplicate checks in `DiscoverJobs` with separate
`exists?` and `insert` calls. Rejected because each backend needs different
atomicity guarantees, and the use case should not coordinate storage races.

### Rename `Persistence` to `Storage`

Replace `FinLimier.Persistence` with `FinLimier.Storage`. `Persistence` implies
durability, but ETS is explicitly volatile. `Storage` is the shared concept
across Postgres, ETS, and possible DETS.

Alternative considered: keep `Persistence` and treat ETS as a persistence
adapter. Rejected because it would make the namespace misleading and obscure the
runtime trade-off.

### Move Ecto under `Storage.Postgres`

Move `FinLimier.Repo` to `FinLimier.Storage.Postgres.Repo` and move the Ecto
schema to `FinLimier.Storage.Postgres.DiscoveredJobOffer`. Add
`FinLimier.Storage.Postgres.JobOfferStore` as the adapter implementing the port.

This makes Postgres an explicit storage backend instead of an application-wide
dependency that use cases can reach directly.

Alternative considered: keep `FinLimier.Repo` at the app root and only add a
store adapter. Rejected because root-level `Repo` keeps Postgres visually and
architecturally central, which conflicts with a configurable storage model.

### Configure storage through `FinLimier.JobDiscovery`

Use the existing job discovery config namespace to select the store:

```elixir
config :fin_limier, FinLimier.JobDiscovery,
  job_offer_store: FinLimier.Storage.Postgres.JobOfferStore
```

Local mode can configure:

```elixir
job_offer_store: FinLimier.Storage.Ets.JobOfferStore
```

Use cases accept an override option for tests and focused runs, following the
current `:source` and `:extractor` pattern.

### Make Postgres startup conditional, but keep Oban tied to Postgres

The application should only start `FinLimier.Storage.Postgres.Repo` and Oban
when Postgres-backed infrastructure is enabled. The first ETS mode can support
manual discovery and the review UI without Postgres; scheduled Oban discovery
remains available only in Postgres mode.

This avoids pretending the app is Postgres-free while Oban still requires a
Postgres repo at boot.

Alternative considered: always start Repo/Oban even when ETS is configured.
Rejected because it would not satisfy the ability to use the app without
Postgres.

## Risks / Trade-offs

- ETS is volatile -> document that discovered offers are lost on application
  restart in ETS mode.
- ETS and Postgres may return different concrete structs -> define a shared
  stored-offer shape or keep templates limited to fields guaranteed by the
  `JobOfferStore` contract.
- Moving `Repo` touches many Phoenix/Ecto conventions -> update config,
  sandbox, release tasks, Oban config, telemetry, and tests in one change.
- Conditional Oban startup changes scheduler availability -> tests and docs
  must make clear that scheduled discovery requires Postgres mode for now.
- Boundary rules may become noisy during the move -> adjust boundaries after
  modules land rather than preserving old dependencies.

## Migration Plan

1. Add the `JobOfferStore` behaviour and update Boundary exports.
2. Create the `Storage` namespace and move Postgres repo/schema modules under
   `Storage.Postgres`.
3. Implement the Postgres store adapter using the moved repo and existing table.
4. Update use cases to call the configured store.
5. Add the ETS store adapter and its supervision/configuration.
6. Update application startup so Postgres repo and Oban are conditional.
7. Update tests, docs, config, release helpers, and architecture decision notes.

Rollback before release is straightforward: restore the root repo module,
restore direct repo calls in use cases, remove the ETS adapter, and revert the
configuration changes.

## Open Questions

- What exact config flag should control Postgres infrastructure startup:
  storage backend, explicit `start_postgres?`, or both?
- Should the ETS store be named/supervised as one global table or through a
  GenServer wrapper?
- Should the LiveView display an explicit indication when storage is volatile?
