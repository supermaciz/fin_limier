defmodule FinLimier.ApplicationTest do
  use ExUnit.Case, async: false

  test "starts Postgres infrastructure for Postgres job offer storage" do
    with_job_offer_store(FinLimier.Storage.Postgres.JobOfferStore, fn ->
      children = FinLimier.Application.children()

      assert FinLimier.Storage.Postgres.Repo in children
      assert Enum.any?(children, &match?({Oban, _opts}, &1))
      refute FinLimier.Storage.Ets.JobOfferStore in children
    end)
  end

  test "starts ETS storage without Postgres infrastructure" do
    with_job_offer_store(FinLimier.Storage.Ets.JobOfferStore, fn ->
      children = FinLimier.Application.children()

      assert FinLimier.Storage.Ets.JobOfferStore in children
      refute FinLimier.Storage.Postgres.Repo in children
      refute Enum.any?(children, &match?({Oban, _opts}, &1))
    end)
  end

  defp with_job_offer_store(store, fun) do
    previous = Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])

    Application.put_env(
      :fin_limier,
      FinLimier.JobDiscovery,
      Keyword.put(previous, :job_offer_store, store)
    )

    try do
      fun.()
    after
      Application.put_env(:fin_limier, FinLimier.JobDiscovery, previous)
    end
  end
end
