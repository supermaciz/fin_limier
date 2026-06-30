## 1. Adapter Contract Tests

- [ ] 1.1 Add tests proving the InstructorLite extractor uses an adapter-owned response model instead of `FinLimier.Core.JobOffer`.
- [ ] 1.2 Add tests proving successful instruction output is mapped into every `FinLimier.Core.JobOffer` field.
- [ ] 1.3 Add tests proving `max_retries` is passed to InstructorLite from explicit options or runtime configuration.

## 2. Instruction Schema

- [ ] 2.1 Create an adapter-layer InstructorLite job offer instruction module with `use Ecto.Schema` and `use InstructorLite.Instruction`.
- [ ] 2.2 Reuse `FinLimier.Core.JobOffer.remote_modes/0` and `seniorities/0` for instruction enum values.
- [ ] 2.3 Add `@notes` describing each extracted field and the semantics of `remote` and `seniority` enum values, including when to use `:unknown`.
- [ ] 2.4 Implement `validate_changeset/2` so InstructorLite validates required fields and enum-compatible output before returning success.

## 3. Extractor Refactor

- [ ] 3.1 Update `FinLimier.Adapters.InstructorLiteExtractor` to use the instruction schema as `response_model`.
- [ ] 3.2 Map successful instruction structs into `%FinLimier.Core.JobOffer{}` before returning from the extractor.
- [ ] 3.3 Add configurable `max_retries` handling with explicit options taking precedence over runtime configuration.
- [ ] 3.4 Preserve existing error containment behavior when InstructorLite returns an error.

## 4. Verification

- [ ] 4.1 Run the focused InstructorLite extractor tests and fix failures.
- [ ] 4.2 Run `mix precommit` and fix any pending issues.
