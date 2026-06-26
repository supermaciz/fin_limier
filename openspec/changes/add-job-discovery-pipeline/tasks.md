## 1. Dependencies and Persistence

- [ ] 1.1 Add Oban and instructor_lite dependencies to `mix.exs`.
- [ ] 1.2 Configure Oban supervision, queues, and test mode.
- [ ] 1.3 Generate and edit Oban database migrations.
- [ ] 1.4 Generate and edit the persisted job offers migration with source metadata and a unique `{source, source_id}` constraint.
- [ ] 1.5 Add the persisted job offer Ecto schema and changeset under the persistence layer.

## 2. Core and Ports

- [ ] 2.1 Extend `FinLimier.Core.JobOffer` with extraction validation through changesets.
- [ ] 2.2 Add `FinLimier.Ports.JobSource` behaviour for fetching raw offers.
- [ ] 2.3 Add `FinLimier.Ports.JobOfferExtractor` behaviour for parsing raw offers into `FinLimier.Core.JobOffer`.
- [ ] 2.4 Add deterministic test stub modules for the source and extractor ports.

## 3. Adapters

- [ ] 3.1 Implement the France Travail source adapter using Req.
- [ ] 3.2 Isolate France Travail authentication/token handling inside the adapter namespace.
- [ ] 3.3 Implement the instructor_lite job offer extractor adapter.
- [ ] 3.4 Add configuration for production adapters and test stubs.

## 4. Use Cases

- [ ] 4.1 Add a `DiscoverJobs` use case that fetches raw offers, parses them, deduplicates them, and persists new records.
- [ ] 4.2 Add a `ListDiscoveredJobs` use case for the review UI.
- [ ] 4.3 Ensure source and parsing failures are contained and inspectable without aborting the full discovery run.
- [ ] 4.4 Add unit tests for use cases using stub ports.

## 5. Worker and Scheduling

- [ ] 5.1 Add `FinLimier.Workers.DiscoverJobsWorker` that calls the discovery use case.
- [ ] 5.2 Configure an Oban cron entry for scheduled discovery.
- [ ] 5.3 Add worker tests covering successful runs and retryable failures.

## 6. LiveView Review Screen

- [ ] 6.1 Add a LiveView route for discovered job offers.
- [ ] 6.2 Implement a discovered offers LiveView wrapped in `<Layouts.app flash={@flash} ...>`.
- [ ] 6.3 Render company, title, remote mode, seniority, location, source, and discovery time.
- [ ] 6.4 Add an empty state for no discovered offers.
- [ ] 6.5 Add LiveView tests using stable DOM IDs and `has_element?/2` selectors.

## 7. Verification

- [ ] 7.1 Run the focused test suite for discovery, worker, and LiveView behavior.
- [ ] 7.2 Run `mix precommit` and fix any reported issues.
