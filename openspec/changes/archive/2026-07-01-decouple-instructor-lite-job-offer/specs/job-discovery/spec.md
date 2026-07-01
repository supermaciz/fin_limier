## MODIFIED Requirements

### Requirement: Raw job offers are parsed into normalized job offer data
The system SHALL parse raw offer text or payloads into normalized `FinLimier.Core.JobOffer` data with company, title, stack, remote mode, seniority, location, and salary fields. LLM-backed parsing SHALL validate extraction output through an adapter-owned instruction schema before returning normalized `FinLimier.Core.JobOffer` data, and SHALL use validation retries when configured for recoverable invalid extraction output.

#### Scenario: Parse a supported raw offer
- **WHEN** a raw offer payload contains enough information for extraction
- **THEN** the system produces a normalized job offer with known fields populated and unknown enum fields set to `:unknown`

#### Scenario: LLM extraction output is validated before normalization
- **WHEN** the InstructorLite-backed extractor receives structured LLM output for a raw offer
- **THEN** the system validates that output with the adapter-owned instruction schema before mapping it into `FinLimier.Core.JobOffer`

#### Scenario: Recoverable LLM validation failure is retried
- **WHEN** the InstructorLite-backed extractor receives invalid structured output and validation retries are configured
- **THEN** the system allows InstructorLite to retry extraction before reporting a parsing failure

#### Scenario: Parsing failure is contained
- **WHEN** a raw offer cannot be parsed into valid job offer data
- **THEN** the system keeps discovery running for other offers and records the parsing failure for inspection
