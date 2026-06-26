## ADDED Requirements

### Requirement: Job offers can be fetched from configured sources
The system SHALL fetch raw job offers from a configured job source through a source port. The first production source MUST be France Travail.

#### Scenario: Fetch offers from France Travail
- **WHEN** job discovery runs with the France Travail source configured
- **THEN** the system requests matching offers from France Travail and returns raw offer payloads for parsing

#### Scenario: Source failure is contained
- **WHEN** the configured source returns an error or an invalid response
- **THEN** the system records the discovery failure without creating job offers from that failed response

### Requirement: Raw job offers are parsed into normalized job offer data
The system SHALL parse raw offer text or payloads into normalized `FinLimier.Core.JobOffer` data with company, title, stack, remote mode, seniority, location, and salary fields.

#### Scenario: Parse a supported raw offer
- **WHEN** a raw offer payload contains enough information for extraction
- **THEN** the system produces a normalized job offer with known fields populated and unknown enum fields set to `:unknown`

#### Scenario: Parsing failure is contained
- **WHEN** a raw offer cannot be parsed into valid job offer data
- **THEN** the system keeps discovery running for other offers and records the parsing failure for inspection

### Requirement: Discovered offers are persisted and deduplicated
The system SHALL persist discovered job offers with source metadata and SHALL avoid creating duplicate records for the same source offer across discovery runs.

#### Scenario: Persist a new offer
- **WHEN** a parsed offer has not previously been stored for its source and source identifier
- **THEN** the system creates a persisted job offer record with normalized fields and source metadata

#### Scenario: Skip an existing offer
- **WHEN** discovery sees an offer with a source and source identifier that already exists
- **THEN** the system does not create a duplicate persisted record

### Requirement: Discovery can run as a background job
The system SHALL expose job discovery as a background worker that can be triggered manually and scheduled periodically.

#### Scenario: Scheduled discovery run
- **WHEN** the scheduled discovery worker runs
- **THEN** the system fetches, parses, deduplicates, and persists offers without requiring a web request

#### Scenario: Retryable worker failure
- **WHEN** a discovery worker fails unexpectedly
- **THEN** the background job system marks the run as failed and makes it eligible for retry according to worker configuration

### Requirement: Users can review discovered offers
The system SHALL provide a LiveView screen where users can review persisted discovered offers.

#### Scenario: List discovered offers
- **WHEN** a user opens the discovered offers screen
- **THEN** the system displays persisted offers with company, title, remote mode, seniority, location, source, and discovery time

#### Scenario: Empty discovery list
- **WHEN** no offers have been persisted yet
- **THEN** the system displays an empty state instead of failing or rendering an empty table without context
