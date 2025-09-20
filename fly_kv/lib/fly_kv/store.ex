defmodule FlyKv.Store do
  @moduledoc """
  Store is a Singleton in-memory key-value store backed by a `GenServer`.
  """
  use GenServer

  alias FlyKv.{Region, Machine}

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def list_regions() do
    GenServer.call(__MODULE__, :list_regions)
  end

  def machines_for_region(region_code) do
    GenServer.call(__MODULE__, {:machines_for_region, region_code})
  end

  def machine_for_region(region_code, machine_key) do
    GenServer.call(__MODULE__, {:machine_for_region, region_code, machine_key})
  end

  # Server callbacks

  @impl true
  def init(_init_arg) do
    {:ok, %{}, {:continue, %{init: :state}}}
  end

  @impl true
  def handle_call(:list_regions, _from, state) do
    {:reply, state.regions, state}
  end

  @impl true
  def handle_call({:machines_for_region, region_code}, _from, state) do
    {:reply, Map.get(state.machines, region_code, %{}), state}
  end

  @impl true
  def handle_call({:machine_for_region, region_code, machine_key}, _from, state) do
    machine =
      state.machines
      |> Map.get(region_code)
      |> Map.get(machine_key)

    {:reply, machine, state}
  end

  @impl true
  def handle_continue(_continue_arg, _state) do
    # IO.inspect(continue_arg, label: "\nA MAP for ARG?\n")
    # IO.inspect(state, label: "\nNOTHING YET for STATE?\n")
    state =
      %{
        regions: Region.read_region_data(),
        machines: Machine.read_machine_data()
      }
    # IO.puts("CONTINUE DATA: #{inspect state}")

    {:noreply, state}
  end
end
