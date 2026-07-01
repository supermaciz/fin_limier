defmodule FinLimier.Storage.Postgres.JobOfferStore do
  @moduledoc """
  Postgres-backed discovered job offer storage adapter.
  """

  @behaviour FinLimier.Ports.JobOfferStore

  import Ecto.Query, only: [from: 2]

  alias FinLimier.Core.JobOffer
  alias FinLimier.Storage.Postgres.DiscoveredJobOffer
  alias FinLimier.Storage.Postgres.Repo
  alias FinLimier.Storage.StoredOffer

  @impl true
  def insert_new(raw_offer, %JobOffer{} = offer) do
    %DiscoveredJobOffer{}
    |> DiscoveredJobOffer.changeset(build_attrs(raw_offer, offer))
    |> Repo.insert()
    |> case do
      {:ok, record} -> {:ok, to_stored_offer(record)}
      {:error, %Ecto.Changeset{} = changeset} -> insert_error(changeset)
    end
  end

  @impl true
  def list_discovered(opts \\ []) do
    query = from o in DiscoveredJobOffer, order_by: [desc: o.discovered_at, desc: o.id]

    query =
      case Keyword.get(opts, :limit) do
        nil -> query
        limit -> from o in query, limit: ^limit
      end

    query
    |> Repo.all()
    |> Enum.map(&to_stored_offer/1)
  end

  defp insert_error(%Ecto.Changeset{} = changeset) do
    if duplicate_constraint_error?(changeset) do
      {:error, :duplicate}
    else
      {:error, changeset}
    end
  end

  defp duplicate_constraint_error?(%Ecto.Changeset{errors: errors}) do
    Enum.any?(errors, fn {field, _} -> field in [:source, :source_id] end)
  end

  defp build_attrs(raw, %JobOffer{} = offer) do
    offer
    |> Map.take([:company, :title, :stack, :remote, :seniority, :location, :salary])
    |> Map.merge(%{
      source: raw.source,
      source_id: raw.source_id,
      source_url: Map.get(raw, :source_url),
      raw_payload: Map.get(raw, :payload, %{}),
      discovered_at: DateTime.utc_now() |> DateTime.truncate(:second)
    })
  end

  defp to_stored_offer(%DiscoveredJobOffer{} = offer) do
    %StoredOffer{
      id: offer.id,
      source: offer.source,
      source_id: offer.source_id,
      source_url: offer.source_url,
      company: offer.company,
      title: offer.title,
      stack: offer.stack,
      remote: offer.remote,
      seniority: offer.seniority,
      location: offer.location,
      salary: offer.salary,
      raw_payload: offer.raw_payload,
      discovered_at: offer.discovered_at
    }
  end
end
