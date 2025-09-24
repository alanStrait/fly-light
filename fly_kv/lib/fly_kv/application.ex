defmodule FlyKv.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FlyKvWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:fly_kv, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FlyKv.PubSub},
      # Start a worker by calling: FlyKv.Worker.start_link(arg)
      # {FlyKv.Worker, arg},
      # Start to serve requests, typically the last entry
      FlyKvWeb.Endpoint,
      # Add GenServer to supervision tree
      FlyKv.Store
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FlyKv.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlyKvWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
