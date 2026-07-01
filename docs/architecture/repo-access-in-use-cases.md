# Configurable job offer storage

Status: supersedes repo access decision - 2026-07-01
Scope: discovered job offer storage

## Decision

Discovered job offers are stored and listed through the
`FinLimier.Ports.JobOfferStore` behaviour. Use cases select the concrete store
from `FinLimier.JobDiscovery` config, with a `:job_offer_store` option override
available for tests and focused runs.

The canonical returned shape is `FinLimier.Storage.StoredOffer`. Adapters map
their native records to that struct at the boundary so LiveView and use cases
can keep simple field access such as `offer.company` and `offer.discovered_at`.

## Storage namespace

`FinLimier.Persistence` was renamed to `FinLimier.Storage`. The old name implied
durable persistence, but the supported backends now include volatile ETS state.
`Storage` covers both durable and non-durable storage without hiding the
runtime trade-off.

Postgres-specific modules live under `FinLimier.Storage.Postgres`:

- `FinLimier.Storage.Postgres.Repo`
- `FinLimier.Storage.Postgres.DiscoveredJobOffer`
- `FinLimier.Storage.Postgres.JobOfferStore`

This keeps Postgres explicit as one storage backend instead of a root-level
application dependency that use cases can reach directly.

## Supported backends

Postgres is the default backend in dev, test, and prod:

```elixir
config :fin_limier, FinLimier.JobDiscovery,
  job_offer_store: FinLimier.Storage.Postgres.JobOfferStore
```

ETS can be selected for local, Postgres-free discovered job storage:

```elixir
config :fin_limier, FinLimier.JobDiscovery,
  job_offer_store: FinLimier.Storage.Ets.JobOfferStore
```

For releases, `JOB_OFFER_STORE=ets` selects the ETS backend at runtime.

ETS storage is volatile. Offers stored in ETS are local runtime state and are
not guaranteed to be present after application restart.

## Background jobs

Oban remains tied to Postgres in this change. When Postgres storage is selected,
the application supervises `FinLimier.Storage.Postgres.Repo` and Oban. When ETS
storage is selected, the application supervises the ETS job offer store and does
not start the Postgres repo or Oban.

Manual discovery and the review UI can run with ETS storage. Scheduled
discovery remains available only in Postgres mode until a Postgres-free
scheduler is introduced.
