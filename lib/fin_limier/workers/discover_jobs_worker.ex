defmodule FinLimier.Workers.DiscoverJobsWorker do
  @moduledoc """
  Runs scheduled job discovery in the background.
  """

  use Oban.Worker, queue: :discovery, max_attempts: 5

  alias FinLimier.UseCases.DiscoverJobs

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    case DiscoverJobs.run() do
      {:ok, _summary} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
