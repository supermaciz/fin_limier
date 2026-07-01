defmodule FinLimier.Adapters.InstructorLite.JobOfferInstruction do
  @moduledoc """
  InstructorLite-specific instruction schema for extracting job offers.

  This adapter-owned schema keeps LLM-facing notes, retry validation, and
  InstructorLite behavior out of the canonical `FinLimier.Core.JobOffer` model.
  The extractor maps successful instruction structs into `Core.JobOffer`.
  """

  use Ecto.Schema
  use InstructorLite.Instruction

  import Ecto.Changeset

  alias FinLimier.Core.JobOffer

  @notes """
  Extract a normalized job offer from the raw source payload.

  Field Descriptions:
  - company: The hiring organization name. Required.
  - title: The job title. Required.
  - stack: Technologies, frameworks, and tools mentioned in the offer.
  - remote: Remote work mode. One of `full` (fully remote), `hybrid` (mix of remote and onsite), `onsite` (no remote), or `unknown` (not stated).
  - seniority: Seniority level. One of `junior`, `mid`, `senior`, or `unknown` (not stated).
  - location: Primary work location (city, region, or country).
  - salary: Salary or compensation description as stated in the offer.

  Use `unknown` for `remote` and `seniority` only when the offer does not provide enough information to decide. Never leave enum fields blank.
  """

  @primary_key false
  embedded_schema do
    field :company, :string
    field :title, :string
    field :stack, {:array, :string}, default: []
    field :remote, Ecto.Enum, values: JobOffer.remote_modes(), default: :unknown
    field :seniority, Ecto.Enum, values: JobOffer.seniorities(), default: :unknown
    field :location, :string
    field :salary, :string
  end

  @cast_fields ~w(company title stack remote seniority location salary)a
  @required_fields ~w(company title)a

  @impl InstructorLite.Instruction
  def validate_changeset(changeset, _opts) do
    changeset
    |> validate_required(@required_fields)
  end

  def changeset(instruction \\ %__MODULE__{}, attrs) do
    instruction
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
