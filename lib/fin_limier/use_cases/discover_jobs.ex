defmodule FinLimier.UseCases.DiscoverJobs do
  @moduledoc """
  Fetches raw offers from a job source, parses them into normalized
  `FinLimier.Core.JobOffer` values, deduplicates them by source identity, and
  persists new records.

  Source failures abort the run (nothing is persisted). Parsing and persistence
  failures for individual offers are contained: discovery keeps running and the
  failures are returned in the summary for inspection.
  """

  alias FinLimier.Core.JobOffer

  @type failure :: %{
          source: String.t() | nil,
          source_id: String.t() | nil,
          stage: :extraction | :persistence,
          reason: term()
        }

  @type summary :: %{
          fetched: non_neg_integer(),
          inserted: non_neg_integer(),
          duplicates: non_neg_integer(),
          failures: [failure()]
        }

  @doc """
  Runs a discovery pass.

  Options:

    * `:source` - module implementing `FinLimier.Ports.JobSource`
      (defaults to the configured source).
    * `:extractor` - module implementing `FinLimier.Ports.JobOfferExtractor`
      (defaults to the configured extractor).
    * `:job_offer_store` - module implementing `FinLimier.Ports.JobOfferStore`
      (defaults to the configured store).
    * `:source_opts` - keyword list forwarded to the source `fetch_offers/1`.
  """
  @spec run(keyword()) :: {:ok, summary()} | {:error, term()}
  def run(opts \\ []) do
    source = Keyword.get(opts, :source, config(:source))
    extractor = Keyword.get(opts, :extractor, config(:extractor))
    job_offer_store = Keyword.get(opts, :job_offer_store, config(:job_offer_store))
    source_opts = Keyword.get(opts, :source_opts, [])

    case source.fetch_offers(source_opts) do
      {:ok, raw_offers} -> {:ok, process(raw_offers, extractor, job_offer_store)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp process(raw_offers, extractor, job_offer_store) do
    initial = %{fetched: length(raw_offers), inserted: 0, duplicates: 0, failures: []}

    Enum.reduce(raw_offers, initial, fn raw, summary ->
      case extractor.extract(raw) do
        {:ok, %JobOffer{} = offer} -> persist(raw, offer, job_offer_store, summary)
        {:error, reason} -> add_failure(summary, raw, :extraction, reason)
      end
    end)
  end

  defp persist(raw, %JobOffer{} = offer, job_offer_store, summary) do
    case job_offer_store.insert_new(raw, offer) do
      {:ok, _stored_offer} ->
        %{summary | inserted: summary.inserted + 1}

      {:error, :duplicate} ->
        %{summary | duplicates: summary.duplicates + 1}

      {:error, reason} ->
        add_failure(summary, raw, :persistence, reason)
    end
  end

  defp add_failure(summary, raw, stage, reason) do
    failure = %{
      source: raw_field(raw, :source),
      source_id: raw_field(raw, :source_id),
      stage: stage,
      reason: reason
    }

    %{summary | failures: summary.failures ++ [failure]}
  end

  defp raw_field(raw, key) when is_map(raw), do: Map.get(raw, key)

  defp config(key) do
    Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])[key]
  end
end
