defmodule FinLimier.Workers.DiscoverJobsWorker do
  @moduledoc """
  Runs scheduled job discovery in the background.
  """

  use Oban.Worker, queue: :discovery, max_attempts: 5

  require Logger

  alias FinLimier.UseCases.DiscoverJobs

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    case DiscoverJobs.run() do
      {:ok, summary} ->
        log_failures(summary)
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp log_failures(%{failures: []}), do: :ok

  defp log_failures(%{failures: failures}) do
    Logger.warning("Job discovery completed with #{length(failures)} offer failure(s): #{inspect(failures)}")
  end
end
