defmodule FinLimier.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Boundary, top_level?: true, deps: [FinLimier, FinLimierWeb]

  @impl true
  def start(_type, _args) do
    children = children()

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FinLimier.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def children do
    [
      FinLimierWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:fin_limier, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FinLimier.PubSub},
      FinLimierWeb.Endpoint
    ]
    |> with_storage_children()
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FinLimierWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp with_storage_children(children) do
    case job_offer_store() do
      FinLimier.Storage.Postgres.JobOfferStore ->
        children
        |> List.insert_at(1, FinLimier.Storage.Postgres.Repo)
        |> List.insert_at(4, {Oban, Application.fetch_env!(:fin_limier, Oban)})

      FinLimier.Storage.Ets.JobOfferStore ->
        List.insert_at(children, 1, FinLimier.Storage.Ets.JobOfferStore)

      _other ->
        children
    end
  end

  defp job_offer_store do
    Application.get_env(:fin_limier, FinLimier.JobDiscovery, [])
    |> Keyword.fetch!(:job_offer_store)
  end
end
