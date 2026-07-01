## MODIFIED Requirements

### Requirement: Discovered offers are persisted and deduplicated
The system SHALL store discovered job offers with source metadata through the
configured job offer storage backend and SHALL avoid creating duplicate records
for the same source offer across discovery runs within that backend.

#### Scenario: Persist a new offer
- **WHEN** a parsed offer has not previously been stored for its source and source identifier in the configured backend
- **THEN** the system creates a stored job offer with normalized fields and source metadata through the configured backend

#### Scenario: Skip an existing offer
- **WHEN** discovery sees an offer with a source and source identifier that already exists in the configured backend
- **THEN** the system does not create a duplicate stored offer

### Requirement: Discovery can run as a background job
The system SHALL expose job discovery as a background worker that can be
triggered manually and scheduled periodically when the configured runtime
includes the background job system.

#### Scenario: Scheduled discovery run
- **WHEN** the scheduled discovery worker runs in a runtime with the background job system enabled
- **THEN** the system fetches, parses, deduplicates, and stores offers without requiring a web request

#### Scenario: Retryable worker failure
- **WHEN** a discovery worker fails unexpectedly in a runtime with the background job system enabled
- **THEN** the background job system marks the run as failed and makes it eligible for retry according to worker configuration

### Requirement: Users can review discovered offers
The system SHALL provide a LiveView screen where users can review discovered
offers from the configured job offer storage backend.

#### Scenario: List discovered offers
- **WHEN** a user opens the discovered offers screen
- **THEN** the system displays stored offers from the configured backend with company, title, remote mode, seniority, location, source, and discovery time

#### Scenario: Empty discovery list
- **WHEN** no offers have been stored in the configured backend yet
- **THEN** the system displays an empty state instead of failing or rendering an empty table without context
