defmodule FinLimier.UseCases.ListDiscoveredJobs do
  @moduledoc """
  Lists stored discovered job offers for the review UI, most recently
  discovered first.
  """

  alias FinLimier.Storage.StoredOffer

  @doc """
  Returns stored discovered offers ordered by discovery time, newest first.

  Options:

    * `:limit` - maximum number of offers to return (defaults to no limit).
    * `:job_offer_store` - module implementing `FinLimier.Ports.JobOfferStore`
      (defaults to the configured store).
  """
  @spec run(keyword()) :: [StoredOffer.t()]
  def run(opts \\ []) do
    opts
    |> Keyword.get(:job_offer_store, config(:job_offer_store))
    |> apply(:list_discovered, [opts])
  end

  defp config(key) do
    Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])[key]
  end
end
