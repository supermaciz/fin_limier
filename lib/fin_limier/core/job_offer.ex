defmodule FinLimier.Core.JobOffer do
  use Ecto.Schema

  import Ecto.Changeset

  @remote_modes [:full, :hybrid, :onsite, :unknown]
  @seniorities [:junior, :mid, :senior, :unknown]

  @primary_key false
  embedded_schema do
    field :company, :string
    field :title, :string
    field :stack, {:array, :string}, default: []
    field :remote, Ecto.Enum, values: @remote_modes, default: :unknown
    field :seniority, Ecto.Enum, values: @seniorities, default: :unknown
    field :location, :string
    field :salary, :string
  end

  @cast_fields ~w(company title stack remote seniority location salary)a
  @required_fields ~w(company title)a

  def changeset(offer \\ %__MODULE__{}, attrs) do
    offer
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end

  def remote_modes, do: @remote_modes
  def seniorities, do: @seniorities
end
