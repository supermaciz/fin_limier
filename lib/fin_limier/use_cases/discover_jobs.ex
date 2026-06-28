defmodule FinLimier.UseCases.DiscoverJobs do
  @moduledoc """
  Fetches raw offers from a job source, parses them into normalized
  `FinLimier.Core.JobOffer` values, deduplicates them by source identity, and
  persists new records.

  Source failures abort the run (nothing is persisted). Parsing and persistence
  failures for individual offers are contained: discovery keeps running and the
  failures are returned in the summary for inspection.
  """

  import Ecto.Query, only: [from: 2]

  alias FinLimier.Core.JobOffer
  alias FinLimier.Persistence.DiscoveredJobOffer
  alias FinLimier.Repo

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
    * `:source_opts` - keyword list forwarded to the source `fetch_offers/1`.
  """
  @spec run(keyword()) :: {:ok, summary()} | {:error, term()}
  def run(opts \\ []) do
    source = Keyword.get(opts, :source, config(:source))
    extractor = Keyword.get(opts, :extractor, config(:extractor))
    source_opts = Keyword.get(opts, :source_opts, [])

    case source.fetch_offers(source_opts) do
      {:ok, raw_offers} -> {:ok, process(raw_offers, extractor)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp process(raw_offers, extractor) do
    initial = %{fetched: length(raw_offers), inserted: 0, duplicates: 0, failures: []}

    Enum.reduce(raw_offers, initial, fn raw, summary ->
      case extractor.extract(raw) do
        {:ok, %JobOffer{} = offer} -> persist(raw, offer, summary)
        {:error, reason} -> add_failure(summary, raw, :extraction, reason)
      end
    end)
  end

  defp persist(raw, %JobOffer{} = offer, summary) do
    if duplicate?(raw) do
      %{summary | duplicates: summary.duplicates + 1}
    else
      changeset = DiscoveredJobOffer.changeset(%DiscoveredJobOffer{}, build_attrs(raw, offer))

      case Repo.insert(changeset) do
        {:ok, _record} -> %{summary | inserted: summary.inserted + 1}
        {:error, %Ecto.Changeset{} = changeset} -> persist_error(summary, raw, changeset)
      end
    end
  end

  defp persist_error(summary, raw, changeset) do
    if duplicate_constraint_error?(changeset) do
      %{summary | duplicates: summary.duplicates + 1}
    else
      add_failure(summary, raw, :persistence, changeset)
    end
  end

  defp duplicate?(%{source: source, source_id: source_id}) do
    Repo.exists?(
      from o in DiscoveredJobOffer, where: o.source == ^source and o.source_id == ^source_id
    )
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
