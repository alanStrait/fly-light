defmodule FlyGlobal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FlyGlobalWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:fly_global, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FlyGlobal.PubSub},
      # Start a worker by calling: FlyGlobal.Worker.start_link(arg)
      # {FlyGlobal.Worker, arg},
      # Start to serve requests, typically the last entry
      FlyGlobalWeb.Endpoint,
      # Add app OTP elements to supervision tree
      {DynamicSupervisor, name: FlyGlobal.MachineSupervisor, strategy: :one_for_one},
      FlyGlobal.ProcessRegistry,
      FlyGlobal.Infrastructure
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlyGlobal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlyGlobalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
