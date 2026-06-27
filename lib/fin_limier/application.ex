defmodule FinLimier.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FinLimierWeb.Telemetry,
      FinLimier.Repo,
      {DNSCluster, query: Application.get_env(:fin_limier, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FinLimier.PubSub},
      {Oban, Application.fetch_env!(:fin_limier, Oban)},
      FinLimierWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FinLimier.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FinLimierWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
