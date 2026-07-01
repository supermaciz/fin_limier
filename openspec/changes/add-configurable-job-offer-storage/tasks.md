## 1. Storage Contract

- [ ] 1.1 Add `FinLimier.Ports.JobOfferStore` behaviour with callbacks for inserting a new discovered offer and listing discovered offers.
- [ ] 1.2 Define the shared stored-offer data shape expected by use cases and LiveView, either as a storage struct or as a documented behaviour return contract.
- [ ] 1.3 Update `FinLimier.Ports` Boundary exports to include `JobOfferStore`.

## 2. Postgres Storage Namespace

- [ ] 2.1 Rename `FinLimier.Persistence` to `FinLimier.Storage` and update Boundary declarations.
- [ ] 2.2 Move `FinLimier.Repo` to `FinLimier.Storage.Postgres.Repo`.
- [ ] 2.3 Move `FinLimier.Persistence.DiscoveredJobOffer` to `FinLimier.Storage.Postgres.DiscoveredJobOffer`.
- [ ] 2.4 Update Ecto config, `ecto_repos`, Oban config, release helpers, telemetry, seeds, migrations references, and test sandbox setup to use the moved repo.
- [ ] 2.5 Implement `FinLimier.Storage.Postgres.JobOfferStore` using the moved repo and schema while preserving current ordering, fields, and duplicate handling.

## 3. Use Case Integration

- [ ] 3.1 Update `DiscoverJobs` to use the configured `JobOfferStore` instead of importing Ecto queries or calling the repo directly.
- [ ] 3.2 Update `ListDiscoveredJobs` to use the configured `JobOfferStore` instead of querying the repo directly.
- [ ] 3.3 Add `:job_offer_store` option overrides to use cases for tests and focused runs, following the existing `:source` and `:extractor` pattern.
- [ ] 3.4 Update worker and LiveView tests affected by the storage contract.

## 4. ETS Storage Backend

- [ ] 4.1 Add `FinLimier.Storage.Ets.JobOfferStore` implementing the `JobOfferStore` behaviour.
- [ ] 4.2 Add supervised ETS initialization for the configured ETS storage table.
- [ ] 4.3 Ensure ETS duplicate detection is keyed by `{source, source_id}` and reports duplicates without creating another stored offer.
- [ ] 4.4 Ensure ETS listing returns discovered offers newest-first and respects the existing `:limit` option.
- [ ] 4.5 Add tests covering ETS insert, duplicate handling, field preservation, list ordering, and limit behavior.

## 5. Runtime Configuration

- [ ] 5.1 Configure Postgres storage as the default backend in existing dev/test/prod settings.
- [ ] 5.2 Add configuration for selecting ETS storage without requiring a Postgres database connection.
- [ ] 5.3 Make application startup conditionally start `FinLimier.Storage.Postgres.Repo` and Oban only when Postgres-backed infrastructure is enabled.
- [ ] 5.4 Add tests or focused checks proving ETS-configured startup does not require the Postgres repo for discovered job storage.

## 6. Documentation and Validation

- [ ] 6.1 Replace or supersede `docs/architecture/repo-access-in-use-cases.md` with the configurable storage decision.
- [ ] 6.2 Update architecture docs to explain `Storage` vs `Persistence`, Postgres repo placement, ETS volatility, and Oban's Postgres-mode limitation.
- [ ] 6.3 Run `mix precommit` and fix any compile, formatting, Boundary, or test issues.
