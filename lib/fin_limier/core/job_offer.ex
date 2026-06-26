defmodule FinLimier.Core.JobOffer do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :company, :string
    field :title, :string
    field :stack, {:array, :string}, default: []
    field :remote, Ecto.Enum, values: [:full, :hybrid, :onsite, :unknown]
    field :seniority, Ecto.Enum, values: [:junior, :mid, :senior, :unknown]
    field :location, :string
    field :salary, :string
  end
end
