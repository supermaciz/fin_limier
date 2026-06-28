defmodule FinLimier.Persistence.DiscoveredJobOffer do
  use Ecto.Schema

  import Ecto.Changeset

  alias FinLimier.Core.JobOffer

  @remote_modes [:full, :hybrid, :onsite, :unknown]
  @seniorities [:junior, :mid, :senior, :unknown]

  @type t :: %__MODULE__{
          source: String.t() | nil,
          source_id: String.t() | nil,
          source_url: String.t() | nil,
          raw_payload: map(),
          company: String.t() | nil,
          title: String.t() | nil,
          stack: [String.t()],
          remote: JobOffer.remote_mode() | nil,
          seniority: JobOffer.seniority() | nil,
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
    field :remote, Ecto.Enum, values: @remote_modes
    field :seniority, Ecto.Enum, values: @seniorities
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
