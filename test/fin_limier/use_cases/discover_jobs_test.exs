defmodule FinLimier.UseCases.DiscoverJobsTest do
  use FinLimier.DataCase, async: false

  alias FinLimier.Persistence.DiscoveredJobOffer
  alias FinLimier.JobDiscovery.StubSource
  alias FinLimier.UseCases.DiscoverJobs

  setup do
    start_supervised!(StubSource)
    StubSource.reset()
    :ok
  end

  defp raw_offer(source_id, payload) do
    %{
      source: "stub",
      source_id: source_id,
      source_url: "https://example.test/#{source_id}",
      payload: payload
    }
  end

  defp valid_payload(overrides \\ %{}) do
    Map.merge(%{"company" => "Acme", "title" => "Backend Engineer"}, overrides)
  end

  test "persists new parsed offers with source metadata" do
    StubSource.put_offers([raw_offer("1", valid_payload(%{"location" => "Paris"}))])

    assert {:ok, summary} = DiscoverJobs.run()
    assert summary.fetched == 1
    assert summary.inserted == 1
    assert summary.duplicates == 0
    assert summary.failures == []

    assert [offer] = Repo.all(DiscoveredJobOffer)
    assert offer.source == "stub"
    assert offer.source_id == "1"
    assert offer.source_url == "https://example.test/1"
    assert offer.company == "Acme"
    assert offer.title == "Backend Engineer"
    assert offer.location == "Paris"
    assert offer.discovered_at != nil
  end

  test "does not create duplicates for the same source offer across runs" do
    StubSource.put_offers([raw_offer("1", valid_payload())])

    assert {:ok, %{inserted: 1}} = DiscoverJobs.run()
    assert {:ok, summary} = DiscoverJobs.run()

    assert summary.inserted == 0
    assert summary.duplicates == 1
    assert Repo.aggregate(DiscoveredJobOffer, :count) == 1
  end

  test "contains parsing failures and keeps discovering other offers" do
    StubSource.put_offers([
      raw_offer("ok", valid_payload()),
      raw_offer("bad", %{"_fail" => :unparseable})
    ])

    assert {:ok, summary} = DiscoverJobs.run()
    assert summary.fetched == 2
    assert summary.inserted == 1
    assert [failure] = summary.failures
    assert failure.source_id == "bad"
    assert failure.stage == :extraction
    assert failure.reason == :unparseable

    assert [offer] = Repo.all(DiscoveredJobOffer)
    assert offer.source_id == "ok"
  end

  test "contains source failures and persists nothing" do
    StubSource.put_error(:boom)

    assert {:error, :boom} = DiscoverJobs.run()
    assert Repo.aggregate(DiscoveredJobOffer, :count) == 0
  end
end
