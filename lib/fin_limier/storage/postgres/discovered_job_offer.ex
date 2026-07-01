defmodule FinLimier.Storage.Postgres.DiscoveredJobOffer do
  use Ecto.Schema

  import Ecto.Changeset

  alias FinLimier.Core.JobOffer

  @remote_modes JobOffer.remote_modes()
  @seniorities JobOffer.seniorities()

  @type t :: %__MODULE__{
          id: integer() | nil,
          source: String.t() | nil,
          source_id: String.t() | nil,
          source_url: String.t() | nil,
          raw_payload: map(),
          company: String.t() | nil,
          title: String.t() | nil,
          stack: [String.t()],
          remote: JobOffer.remote_mode(),
          seniority: JobOffer.seniority(),
          location: String.t() | nil,
          salary: String.t() | nil,
          discovered_at: DateTime.t() | nil
        }

  schema "discovered_job_offers" do
    field :source, :string
    field :source_id, :string
    field :source_url, :string
    field :raw_payload, :map, default: %{}

    field :company, :string
    field :title, :string
    field :stack, {:array, :string}, default: []
    field :remote, Ecto.Enum, values: @remote_modes, default: :unknown
    field :seniority, Ecto.Enum, values: @seniorities, default: :unknown
    field :location, :string
    field :salary, :string

    field :discovered_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @required_fields ~w(source source_id discovered_at)a
  @optional_fields ~w(source_url raw_payload company title stack remote seniority location salary)a

  def changeset(offer, attrs) do
    offer
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:source, :source_id])
  end
end
