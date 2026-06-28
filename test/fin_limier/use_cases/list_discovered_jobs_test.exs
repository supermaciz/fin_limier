defmodule FinLimier.UseCases.ListDiscoveredJobsTest do
  use FinLimier.DataCase, async: true

  alias FinLimier.Persistence.DiscoveredJobOffer
  alias FinLimier.Repo
  alias FinLimier.UseCases.ListDiscoveredJobs

  defp insert_offer(source_id, discovered_at) do
    %DiscoveredJobOffer{}
    |> DiscoveredJobOffer.changeset(%{
      source: "stub",
      source_id: source_id,
      discovered_at: discovered_at,
      company: "Acme",
      title: "Engineer #{source_id}"
    })
    |> Repo.insert!()
  end

  test "returns an empty list when no offers are persisted" do
    assert ListDiscoveredJobs.run() == []
  end

  test "returns persisted offers most recently discovered first" do
    older = insert_offer("old", ~U[2026-06-01 10:00:00Z])
    newer = insert_offer("new", ~U[2026-06-20 10:00:00Z])

    assert [first, second] = ListDiscoveredJobs.run()
    assert first.id == newer.id
    assert second.id == older.id
  end
end
