defmodule FinLimier.Workers.DiscoverJobsWorkerTest do
  use FinLimier.DataCase, async: false

  import Oban.Testing, only: [perform_job: 3]

  alias FinLimier.JobDiscovery.StubSource
  alias FinLimier.UseCases.ListDiscoveredJobs
  alias FinLimier.Workers.DiscoverJobsWorker

  setup do
    start_supervised!(StubSource)
    StubSource.reset()
    :ok
  end

  test "performs a successful discovery run" do
    StubSource.put_offers([
      %{
        source: "stub",
        source_id: "worker-1",
        source_url: "https://example.test/worker-1",
        payload: %{"company" => "Acme", "title" => "Backend Engineer"}
      }
    ])

    assert :ok = perform_job(DiscoverJobsWorker, %{}, [])
    assert [%{source_id: "worker-1"}] = ListDiscoveredJobs.run()
  end

  test "returns an error for retryable discovery failures" do
    StubSource.put_error(:temporary_failure)

    assert {:error, :temporary_failure} = perform_job(DiscoverJobsWorker, %{}, [])
    assert ListDiscoveredJobs.run() == []
  end

  test "is configured for scheduled discovery" do
    assert {Oban.Plugins.Cron, cron_opts} =
             Application.fetch_env!(:fin_limier, Oban)
             |> Keyword.fetch!(:plugins)
             |> Enum.find(&match?({Oban.Plugins.Cron, _opts}, &1))

    assert {"0 * * * *", DiscoverJobsWorker} in Keyword.fetch!(cron_opts, :crontab)
  end
end
