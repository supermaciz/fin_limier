defmodule FinLimier.UseCases.ListDiscoveredJobsTest do
  use FinLimier.DataCase, async: true

  alias FinLimier.Core.JobOffer
  alias FinLimier.Storage.Postgres.JobOfferStore
  alias FinLimier.UseCases.ListDiscoveredJobs

  defp insert_offer(source_id) do
    {:ok, offer} =
      JobOfferStore.insert_new(raw_offer(source_id), %JobOffer{
        company: "Acme",
        title: "Engineer #{source_id}"
      })

    offer
  end

  test "returns an empty list when no offers are persisted" do
    assert ListDiscoveredJobs.run() == []
  end

  test "returns persisted offers most recently discovered first" do
    older = insert_offer("old")
    newer = insert_offer("new")

    assert [first, second] = ListDiscoveredJobs.run()
    assert first.source_id == newer.source_id
    assert second.source_id == older.source_id
  end

  defp raw_offer(source_id) do
    %{
      source: "stub",
      source_id: source_id,
      payload: %{}
    }
  end
end
