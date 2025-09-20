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

  @spec list_regions :: list(Region.t())
  def list_regions() do
    GenServer.call(__MODULE__, :list_regions)
  end

  @spec machines_for_region(binary) :: list(Machine.t())
  def machines_for_region(region_code) do
    GenServer.call(__MODULE__, {:machines_for_region, region_code})
  end

  @spec machine_for_region(binary(), binary()) :: Machine.t()
  def machine_for_region(region_code, machine_key) do
    GenServer.call(__MODULE__, {:machine_for_region, region_code, machine_key})
  end

  @spec machine_request(binary(), integer(), integer()) :: Machine.t()
  def machine_request(region_code, memory_needed, cores_needed) do
    GenServer.call(__MODULE__, {:machine_request, region_code, memory_needed, cores_needed})
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
  def handle_call({:machine_request, region_code, memory_needed, cores_needed}, _from, state) do
    # machines for regions
    {key, machine} =
      state.machines
      |> Map.get(region_code, %{})
      # filter candidates
      |> Enum.filter(fn {_key, machine} ->
        ((machine.memory_total - machine.memory_allocated) > memory_needed) &&
        ((machine.cores_total - machine.cores_allocated) > cores_needed)
      end)
      # ordered randomly
      |> Enum.shuffle()
      # allocate first match
      |> List.first() || nil

    machine_prime = %Machine{
      machine |
      memory_allocated: machine.memory_allocated + memory_needed,
      cores_allocated: machine.cores_allocated + cores_needed
    }

    state = put_machine(state, region_code, key, machine_prime)

    {:reply, machine_prime, state}
  end

  @impl true
  def handle_continue(_continue_arg, _state) do
    state =
      %{
        regions: Region.read_region_data(),
        machines: Machine.read_machine_data()
      }

    {:noreply, state}
  end

  defp put_machine(state, region_code, machine_key, machine) do
    update_in(
      state,
      [:machines, region_code, machine_key],
      fn _machine -> machine
    end)
  end
end
