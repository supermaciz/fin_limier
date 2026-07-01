## Why

The current InstructorLite-backed extraction uses `FinLimier.Core.JobOffer` directly as the response model, which risks coupling the core domain model to LLM-specific prompting, notes, and retry validation behavior. As additional extractors become plausible, job discovery needs a stable canonical `Core.JobOffer` contract while allowing each adapter to own its extraction-specific schema and validation semantics.

## What Changes

- Introduce an InstructorLite-specific job offer instruction schema owned by the adapter layer.
- Keep `FinLimier.Core.JobOffer` as the normalized domain output expected by the job discovery port and use cases.
- Configure the InstructorLite extractor to request the adapter instruction schema, validate LLM output through InstructorLite's instruction callback, and map successful results into `Core.JobOffer`.
- Add semantic field notes for enum values and extraction rules so the LLM has clearer guidance.
- Add retry configuration for InstructorLite validation failures.
- No breaking changes to the `FinLimier.Ports.JobOfferExtractor` contract.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `job-discovery`: LLM-backed parsing SHALL validate extraction output through an adapter-owned InstructorLite instruction schema before returning normalized `FinLimier.Core.JobOffer` data.

## Impact

- Affects `FinLimier.Adapters.InstructorLiteExtractor` and related adapter tests.
- Adds an adapter-layer InstructorLite instruction module.
- Keeps `FinLimier.Core.JobOffer`, discovery use cases, persistence, and the job offer extractor port centered on the canonical domain model.
- Uses the existing `instructor_lite` dependency; no new dependency is expected.
