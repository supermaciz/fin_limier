# Job Offer Storage

## Purpose

Provide configurable storage for discovered job offers so the application can
use Postgres-backed durable storage or ETS-backed local volatile storage.

## Requirements

### Requirement: Job offer storage is configurable
The system SHALL store and list discovered job offers through a configured job
offer storage backend. The system MUST provide a Postgres-backed storage backend
and an ETS-backed storage backend.

#### Scenario: Use configured Postgres storage
- **WHEN** job offer storage is configured to use Postgres
- **THEN** the system stores and lists discovered offers through the Postgres storage backend

#### Scenario: Use configured ETS storage
- **WHEN** job offer storage is configured to use ETS
- **THEN** the system stores and lists discovered offers through the ETS storage backend without requiring Postgres

### Requirement: Stored offers preserve review fields
The system SHALL expose stored discovered offers with source metadata,
normalized job fields, and discovery time regardless of the configured storage
backend.

#### Scenario: Read stored offer fields
- **WHEN** a discovered offer is stored through any supported backend
- **THEN** the stored offer includes source, source identifier, source URL when available, company, title, stack, remote mode, seniority, location, salary, raw payload, and discovery time

### Requirement: Storage deduplicates by source identity
The system SHALL prevent duplicate discovered offers for the same source and
source identifier within the configured storage backend.

#### Scenario: Insert first source offer
- **WHEN** a source and source identifier have not been stored in the configured backend
- **THEN** the storage backend accepts the discovered offer as a new record

#### Scenario: Reject duplicate source offer
- **WHEN** a source and source identifier already exist in the configured backend
- **THEN** the storage backend reports the offer as a duplicate without creating another stored offer

### Requirement: ETS storage is volatile
The system SHALL treat ETS-backed job offer storage as local runtime state that
does not survive application restart.

#### Scenario: Restart with ETS storage
- **WHEN** the application restarts while configured with ETS job offer storage
- **THEN** previously discovered ETS-stored offers are not guaranteed to be available

### Requirement: Postgres infrastructure is optional for local storage
The system SHALL allow the application to start without the Postgres Ecto repo
when the configured job offer storage backend does not require Postgres.

#### Scenario: Start with ETS storage
- **WHEN** the application starts with ETS job offer storage configured
- **THEN** the application does not require a Postgres database connection for discovered job storage

#### Scenario: Start with Postgres storage
- **WHEN** the application starts with Postgres job offer storage configured
- **THEN** the application starts the Postgres Ecto repo needed by that backend
