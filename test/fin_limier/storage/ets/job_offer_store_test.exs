defmodule FinLimier.Storage.Ets.JobOfferStoreTest do
  use ExUnit.Case, async: false

  alias FinLimier.Core.JobOffer
  alias FinLimier.Storage.Ets.JobOfferStore
  alias FinLimier.Storage.StoredOffer

  setup do
    previous = Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])
    table = :"fin_limier_ets_store_test_#{System.unique_integer([:positive])}"

    Application.put_env(
      :fin_limier,
      FinLimier.JobDiscovery,
      Keyword.merge(previous, ets_job_offer_table: table)
    )

    start_supervised!(JobOfferStore)

    on_exit(fn -> Application.put_env(:fin_limier, FinLimier.JobDiscovery, previous) end)

    :ok
  end

  test "inserts a discovered offer and preserves review fields" do
    assert {:ok, %StoredOffer{} = stored_offer} =
             JobOfferStore.insert_new(raw_offer("1"), job_offer(location: "Paris"))

    assert is_integer(stored_offer.id)
    assert stored_offer.source == "stub"
    assert stored_offer.source_id == "1"
    assert stored_offer.source_url == "https://example.test/1"
    assert stored_offer.raw_payload == %{"id" => "1"}
    assert stored_offer.company == "Acme"
    assert stored_offer.title == "Elixir Engineer"
    assert stored_offer.stack == ["Elixir", "Phoenix"]
    assert stored_offer.remote == :hybrid
    assert stored_offer.seniority == :senior
    assert stored_offer.location == "Paris"
    assert stored_offer.salary == "EUR 80k"
    assert %DateTime{} = stored_offer.discovered_at
  end

  test "deduplicates by source and source_id" do
    assert {:ok, %StoredOffer{id: id}} = JobOfferStore.insert_new(raw_offer("1"), job_offer())
    assert {:error, :duplicate} = JobOfferStore.insert_new(raw_offer("1"), job_offer())

    assert [%StoredOffer{id: ^id}] = JobOfferStore.list_discovered()
  end

  test "lists offers newest first and respects limit" do
    assert {:ok, older} = JobOfferStore.insert_new(raw_offer("1"), job_offer(title: "Older"))
    assert {:ok, newer} = JobOfferStore.insert_new(raw_offer("2"), job_offer(title: "Newer"))

    assert [^newer, ^older] = JobOfferStore.list_discovered()
    assert [^newer] = JobOfferStore.list_discovered(limit: 1)
  end

  defp raw_offer(source_id) do
    %{
      source: "stub",
      source_id: source_id,
      source_url: "https://example.test/#{source_id}",
      payload: %{"id" => source_id}
    }
  end

  defp job_offer(attrs \\ []) do
    struct!(
      JobOffer,
      Keyword.merge(
        [
          company: "Acme",
          title: "Elixir Engineer",
          stack: ["Elixir", "Phoenix"],
          remote: :hybrid,
          seniority: :senior,
          location: "Remote",
          salary: "EUR 80k"
        ],
        attrs
      )
    )
  end
end
