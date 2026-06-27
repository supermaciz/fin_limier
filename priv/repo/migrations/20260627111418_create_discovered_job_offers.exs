defmodule FinLimier.Repo.Migrations.CreateDiscoveredJobOffers do
  use Ecto.Migration

  def change do
    create table(:discovered_job_offers) do
      add :source, :string, null: false
      add :source_id, :string, null: false
      add :source_url, :string
      add :raw_payload, :map, null: false, default: %{}

      add :company, :string
      add :title, :string
      add :stack, {:array, :string}, null: false, default: []
      add :remote, :string
      add :seniority, :string
      add :location, :string
      add :salary, :string

      add :discovered_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:discovered_job_offers, [:source, :source_id])
    create index(:discovered_job_offers, [:discovered_at])
  end
end
