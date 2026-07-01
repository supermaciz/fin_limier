defmodule FinLimier.Storage.Ets.JobOfferStore do
  @moduledoc """
  ETS-backed volatile discovered job offer storage adapter.
  """

  use GenServer

  @behaviour FinLimier.Ports.JobOfferStore

  alias FinLimier.Core.JobOffer
  alias FinLimier.Storage.StoredOffer

  @impl true
  def insert_new(raw_offer, %JobOffer{} = offer) do
    stored_offer = to_stored_offer(raw_offer, offer)
    key = key(raw_offer.source, raw_offer.source_id)

    case :ets.insert_new(table(), {key, stored_offer}) do
      true -> {:ok, stored_offer}
      false -> {:error, :duplicate}
    end
  end

  @impl true
  def list_discovered(opts \\ []) do
    limit = Keyword.get(opts, :limit)

    table()
    |> :ets.tab2list()
    |> Enum.map(fn {_key, offer} -> offer end)
    |> Enum.sort_by(&{DateTime.to_unix(&1.discovered_at), &1.id}, :desc)
    |> maybe_limit(limit)
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    :ets.new(table(), [:named_table, :public, read_concurrency: true])
    {:ok, %{}}
  end

  defp to_stored_offer(raw, %JobOffer{} = offer) do
    %StoredOffer{
      id: System.unique_integer([:positive, :monotonic]),
      source: raw.source,
      source_id: raw.source_id,
      source_url: Map.get(raw, :source_url),
      raw_payload: Map.get(raw, :payload, %{}),
      company: offer.company,
      title: offer.title,
      stack: offer.stack,
      remote: offer.remote,
      seniority: offer.seniority,
      location: offer.location,
      salary: offer.salary,
      discovered_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end

  defp maybe_limit(offers, nil), do: offers
  defp maybe_limit(offers, limit), do: Enum.take(offers, limit)

  defp key(source, source_id), do: {source, source_id}

  defp table do
    Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])
    |> Keyword.get(:ets_job_offer_table, :fin_limier_job_offers)
  end
end
