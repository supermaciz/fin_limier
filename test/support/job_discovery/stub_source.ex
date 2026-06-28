defmodule FinLimier.JobDiscovery.StubSource do
  @moduledoc """
  Deterministic in-memory source used by tests only. Configure with
  `put_offers/1` (default: empty list) or `put_error/1` to exercise containment.
  """

  use Boundary, deps: [FinLimier.Core, FinLimier.Ports]

  @behaviour FinLimier.Ports.JobSource

  use Agent

  def start_link(_), do: Agent.start_link(fn -> %{response: {:ok, []}} end, name: __MODULE__)

  defp ensure_started do
    case start_link(nil) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
  end

  def put_offers(offers) when is_list(offers) do
    ensure_started()
    Agent.update(__MODULE__, &Map.put(&1, :response, {:ok, offers}))
  end

  def put_error(reason) do
    ensure_started()
    Agent.update(__MODULE__, &Map.put(&1, :response, {:error, reason}))
  end

  def reset do
    ensure_started()
    Agent.update(__MODULE__, fn _ -> %{response: {:ok, []}} end)
  end

  @impl true
  def fetch_offers(_opts) do
    ensure_started()
    Agent.get(__MODULE__, & &1.response)
  end
end
