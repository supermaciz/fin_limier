## Context

Job discovery currently parses raw offers through the `FinLimier.Ports.JobOfferExtractor` contract, whose successful output is `FinLimier.Core.JobOffer`. The InstructorLite adapter currently passes `Core.JobOffer` directly as the `response_model`, even though InstructorLite response models can carry LLM-specific concerns such as `@notes`, `use InstructorLite.Instruction`, and `validate_changeset/2` retry validation.

Keeping those concerns in `Core.JobOffer` would be simple, but it would make the core domain model depend on one adapter technology. Since additional extractors are plausible, the adapter boundary should absorb InstructorLite-specific schema and validation details while preserving `Core.JobOffer` as the canonical normalized offer shape.

## Goals / Non-Goals

**Goals:**

- Keep `FinLimier.Core.JobOffer` independent from InstructorLite-specific behavior.
- Add an adapter-owned InstructorLite instruction schema for LLM response validation and semantic field guidance.
- Enable InstructorLite validation retry behavior through `validate_changeset/2` and `max_retries`.
- Preserve the existing `FinLimier.Ports.JobOfferExtractor` output contract.
- Keep enum definitions aligned with the core domain model.

**Non-Goals:**

- Do not introduce new external dependencies.
- Do not change persistence schema or discovered job display behavior.
- Do not redesign job discovery source fetching or worker scheduling.
- Do not add support for additional extractors in this change; only prepare the boundary for them.

## Decisions

### Use an Adapter-Owned Instruction Schema

Create a module under the InstructorLite adapter namespace, such as `FinLimier.Adapters.InstructorLite.JobOfferInstruction`, with `use Ecto.Schema` and `use InstructorLite.Instruction`.

Rationale: this keeps prompt/schema/retry semantics close to the adapter and prevents `FinLimier.Core` from depending on InstructorLite. The adapter may depend on core enums and map into core structs, but the reverse dependency is avoided.

Alternative considered: add `use InstructorLite.Instruction` directly to `Core.JobOffer`. This is smaller but couples the domain model to one extraction implementation.

### Keep Core.JobOffer as the Port Output

`FinLimier.Ports.JobOfferExtractor.extract/2` continues to return `{:ok, %FinLimier.Core.JobOffer{}}` on success. The InstructorLite extractor maps `%JobOfferInstruction{}` into `%Core.JobOffer{}` after successful validation.

Rationale: use cases, persistence, and future extractors share one stable normalized representation.

Alternative considered: make the port return adapter-native structs. This would leak adapter details into use cases and complicate future extractor interoperability.

### Reuse Core Enum Values in the Instruction Schema

The instruction schema should use `JobOffer.remote_modes()` and `JobOffer.seniorities()` for `Ecto.Enum` values.

Rationale: this avoids drift between the LLM-facing schema and the canonical domain model while preserving dependency direction from adapter to core.

Alternative considered: duplicate enum lists in the adapter. This would reduce imports but increase the risk of mismatch.

### Put Mapping in the Extractor Initially

Keep conversion from instruction struct to core struct private to `InstructorLiteExtractor` unless reuse emerges.

Rationale: the mapping is part of fulfilling the port contract and does not need a public API yet.

Alternative considered: expose `JobOfferInstruction.to_core/1`. This may become useful later, but starting private keeps the adapter surface smaller.

### Configure Validation Retries at the Adapter Boundary

Pass `max_retries` to `InstructorLite.instruct/2`, using explicit options first and runtime configuration as the fallback.

Rationale: retry policy belongs to the adapter behavior, not the core domain model. Explicit options keep tests and callers deterministic.

## Risks / Trade-offs

- Duplicate schema fields between `Core.JobOffer` and `JobOfferInstruction` -> Mitigate by reusing core enum lists and keeping the instruction schema intentionally narrow.
- Mapping bugs could drop fields -> Mitigate with adapter tests that assert every normalized field is transferred.
- Validation may be too strict and increase retry/failure rates -> Mitigate by starting with required fields and enum semantics, then tightening only when evidence supports it.
- Runtime retry configuration could be unclear -> Mitigate by documenting the option in tests and keeping a conservative default.

## Migration Plan

No data migration is required. Implementation can be shipped as an internal adapter refactor because the job offer extractor port, discovery use cases, and persistence schema remain unchanged.

Rollback is straightforward: restore `response_model: JobOffer` in the InstructorLite extractor and remove the adapter instruction module.

## Open Questions

- What default `max_retries` should be used in production: `1` for minimal extra cost or a higher value for improved extraction robustness?
- Should the instruction schema normalize empty strings to nil during validation, or should that remain a later cleanup concern?
