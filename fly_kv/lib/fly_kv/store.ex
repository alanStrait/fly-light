defmodule FlyKv.Store do
  @moduledoc """
  Store is a Singleton in-memory key-value store backed by a `GenServer`.
  """
  use GenServer

  alias FlyKv.{Region, Machine}

  # Client API

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc """
  list_regions returns a list of all `Region`s in which flylight has
  co-located servers for use by customers.
  """
  @spec list_regions :: list(Region.t())
  def list_regions() do
    GenServer.call(__MODULE__, :list_regions)
  end

  @doc """
  fetch_regions_with_machines provides combined dataset for a single SLA.
  """
  def fetch_regions_with_machines() do
    GenServer.call(__MODULE__, :fetch_regions_with_machines)
  end

  def machine_candidates_for(region_code, memory, cores, num_candidates) do
    GenServer.call(
      __MODULE__,
      {:machine_candidates_for, region_code, memory, cores, num_candidates}
    )
  end

  @doc """
  machines_for_region returns a list of machines and their state for
  a given region_code.
  """
  @spec machines_for_region(binary) :: list(Machine.t())
  def machines_for_region(region_code) do
    GenServer.call(__MODULE__, {:machines_for_region, region_code})
  end

  @doc """
  machine_for_region returns the details known about a machine
  identified by `region_code` and `machine_key`.
  """
  @spec machine_for_region(binary(), binary()) :: Machine.t()
  def machine_for_region(region_code, machine_key) do
    GenServer.call(__MODULE__, {:machine_for_region, region_code, machine_key})
  end

  @doc """
  machine_request asks for a VM to be allocated according to provided
  parameters: region_code, memory_needed, and cores_needed.  If space allows
  the machine is provisioned and returned in this synchronous request.
  """
  @spec machine_request(binary(), integer(), integer()) :: Machine.t()
  def machine_request(region_code, memory_needed, cores_needed) do
    GenServer.call(__MODULE__, {:machine_request, region_code, memory_needed, cores_needed})
  end

  def update_machine(region_code, address, memory_allocated, cores_allocated, status) do
    GenServer.call(
      __MODULE__,
      {:update_machine, region_code, address, memory_allocated, cores_allocated, status}
    )
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

  def handle_call(:fetch_regions_with_machines, _from, state) do
    regions =
      state.regions
      |> Enum.map(fn {_key, region} ->
        machines_p =
          state.machines
          |> Map.get(region.code, %{})
          |> Enum.into([], fn {_k, machine} -> machine end)

        update_in(region.machines, fn _machines -> machines_p end)
      end)

    {:reply, regions, state}
  end

  @impl true
  def handle_call(
        {:machine_candidates_for, region_code, memory, cores, num_candidates},
        _from,
        state
      ) do
    candidates =
      state.machines
      |> Map.get(region_code, %{})
      |> Map.filter(fn {_k, machine} ->
        machine.memory_total - machine.memory_allocated >= memory &&
          machine.cores_total - machine.cores_allocated >= cores
      end)
      |> Enum.shuffle()
      |> Enum.take(num_candidates)
      |> Enum.into([], &elem(&1, 1))

    {:reply, candidates, state}
  end

  @impl true
  def handle_call({:machines_for_region, region_code}, _from, state) do
    {:reply, Map.get(state.machines, region_code, %{}), state}
  end

  @impl true
  def handle_call({:machine_for_region, region_code, machine_address}, _from, state) do
    machine = fetch_machine(state, region_code, machine_address)

    {:reply, machine, state}
  end

  @impl true
  def handle_call({:machine_request, region_code, memory_needed, cores_needed}, _from, state) do
    # machines for regions
    machine_kv =
      state.machines
      |> Map.get(region_code, %{})
      # filter candidates
      |> Enum.filter(fn {_key, machine} ->
        machine.memory_total - machine.memory_allocated > memory_needed &&
          machine.cores_total - machine.cores_allocated > cores_needed
      end)
      # choose random server
      |> Enum.shuffle()
      # allocate first match
      |> List.first()

    now = DateTime.utc_now()

    {machine, state} =
      if machine_kv == nil do
        {nil, state}
      else
        {key, machine} = machine_kv

        machine_prime = %Machine{
          machine
          | memory_allocated: machine.memory_allocated + memory_needed,
            cores_allocated: machine.cores_allocated + cores_needed,
            updated_at: now
        }

        state = put_machine(state, region_code, key, machine_prime)

        {machine_prime, state}
      end

    {:reply, machine, state}
  end

  def handle_call(
        {:update_machine, region_code, address, memory_allocated, cores_allocated, status},
        _from,
        state
      ) do
    case fetch_machine(state, region_code, address) do
      nil ->
        {:reply, {:error, "Machine not found"}, state}

      machine ->
        key = compose_key(region_code, address)

        machine_prime = %Machine{
          machine
          | memory_allocated: machine.memory_allocated + memory_allocated,
            cores_allocated: machine.cores_allocated + cores_allocated,
            status: status
        }

        state_prime = put_machine(state, region_code, key, machine_prime)
        {:reply, {:ok, machine_prime}, state_prime}
    end
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

  defp fetch_machine(state, region_code, machine_address) do
    state.machines
    |> Map.get(region_code)
    |> Map.get(compose_key(region_code, machine_address))
  end

  defp put_machine(state, region_code, machine_key, machine) do
    update_in(
      state,
      [:machines, region_code, machine_key],
      fn _machine -> machine end
    )
  end

  defp compose_key(region_code, machine_address) do
    region_code <> "::" <> machine_address
  end
end
