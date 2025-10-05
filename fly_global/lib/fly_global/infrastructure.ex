defmodule FlyGlobal.Infrastructure do
  use GenServer

  @moduledoc """
  Infrastucture is a `GenServer` that sets up `MachineeD` and `FlyD`
  GenServers using FlyKv data describing available machines by region.
  """

  # Client API
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  # Server callbacks
  def init(init_arg) do
    IO.puts("Infrastructure init arg #{inspect init_arg}")
    {:ok, %{}, {:continue, %{init: :state}}}
  end

  def handle_continue(continue_arg, state) do
    IO.puts("\nhandle_continue arg #{inspect continue_arg}\n")
    IO.puts("\n\t state #{inspect state}\n")
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
            IO.inspect(error, label: "\nERROR starting process\n")
            error
        end
      end)

  end
end
