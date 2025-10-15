defmodule FlyGlobal.Infrastructure do
  @moduledoc """
  Infrastucture is a `GenServer` that sets up `MachineeD` and `FlyD`
  GenServers using FlyKv data describing available machines by region.
  """

  require Logger
  use GenServer

  # Client API
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  # Server callbacks
  def init(_arg) do
    {:ok, %{}, {:continue, nil}}
  end

  def handle_continue(_continue_arg, state) do
    regions =
      FlyGlobal.fetch_regions()
      |> Enum.filter(fn region -> length(region["machines"]) > 0 end)

    start_processes(regions, FlyGlobal.MachineD)
    start_processes(regions, FlyGlobal.FlyD)

    {:noreply, state}
  end

  def start_processes(regions, module) do
      regions
      |> Enum.into([], fn region ->
        for machine <- region["machines"] do
          {module, {region["code"], machine}}
        end
      end)
      |> Enum.flat_map(&(&1))
      |> Enum.each(fn spec ->
        case DynamicSupervisor.start_child(FlyGlobal.MachineSupervisor, spec) do
          {:ok, _pid} -> :ok

          error ->
            Logger.warning("\nERROR starting process #{inspect error}\n")
            error
        end
      end)

  end
end
