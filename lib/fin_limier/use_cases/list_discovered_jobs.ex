defmodule FinLimier.UseCases.ListDiscoveredJobs do
  @moduledoc """
  Lists persisted discovered job offers for the review UI, most recently
  discovered first.
  """

  import Ecto.Query, only: [from: 2]

  alias FinLimier.Persistence.DiscoveredJobOffer
  alias FinLimier.Repo

  @doc """
  Returns persisted discovered offers ordered by discovery time, newest first.

  Options:

    * `:limit` - maximum number of offers to return (defaults to no limit).
  """
  @spec run(keyword()) :: [DiscoveredJobOffer.t]
  def run(opts \\ []) do
    query = from o in DiscoveredJobOffer, order_by: [desc: o.discovered_at, desc: o.id]

    query =
      case Keyword.get(opts, :limit) do
        nil -> query
        limit -> from o in query, limit: ^limit
      end

    Repo.all(query)
  end
end
