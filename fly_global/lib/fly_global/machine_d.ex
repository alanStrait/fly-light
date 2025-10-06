defmodule FlyGlobal.MachineD do
  use GenServer

  alias FlyGlobal.ProcessRegistry

  @derive Jason.Encoder
  defstruct [
    :region_code,
    :address,
    :memory_total,
    :memory_allocated,
    :memory_available,
    :cores_total,
    :cores_allocated,
    :cores_available,
    :status
  ]

  @type t :: %__MODULE__{
          region_code: String.t(),
          address: String.t(),
          memory_total: integer(),
          memory_allocated: integer(),
          memory_available: integer(),
          cores_total: integer(),
          cores_allocated: integer(),
          cores_available: integer(),
          status: String.t()
        }

  # Client API
  def allocate_vm(region_code, machine_address, memory_gb, cores) do
    GenServer.call(
      via_tuple(compose_key(region_code, machine_address)),
      {:allocate_vm, memory_gb, cores}
    )
  end

  def start_link({region_code, machine}) do
    key = compose_key(region_code, machine)

    GenServer.start_link(
      __MODULE__,
      {region_code, machine},
      name: via_tuple(key)
    )
  end

  defp via_tuple(key) do
    ProcessRegistry.via_tuple(key)
  end

  # Server callbacks
  @impl true
  def handle_call({:allocate_vm, memory_gb, cores}, _from, state) do
    IO.inspect(state, label: "\nSTATE BEFORE\n")
    memory = memory_gb * 1_000_000_000
    {result, state_new} =
      if (state.memory_available >= memory && state.cores_available >= cores) do
        state_prime =
          %__MODULE__{
            state |
            memory_allocated: state.memory_allocated + memory,
            memory_available: state.memory_total - (state.memory_allocated + memory),
            cores_allocated: state.cores_allocated + cores,
            cores_available: state.cores_total - (state.cores_allocated + cores)
          }
        {:ok, state_prime}
      else
        state_prime =
          %__MODULE__{ state | status: "unavailable" }
        {:unavailable, state_prime}
      end
    IO.inspect(state, label: "\nHANDLE_CALL\n")
    IO.puts("memory_gb #{memory_gb} cores #{cores}")

    {:reply, {result, state_new}, state_new}
  end

  @impl true
  def init(init_args) do
    {:ok, %{}, {:continue, init_args}}
  end

  @impl true
  def handle_continue({region_code, machine}, state) do
    IO.puts("\nstate\t #{inspect state}")
    machine_d =
      %__MODULE__{
        region_code: region_code,
        address: machine["address"],
        memory_total: machine["memory_total"],
        memory_allocated: machine["memory_allocated"],
        memory_available: machine["memory_total"] - machine["memory_allocated"],
        cores_total: machine["cores_total"],
        cores_allocated: machine["cores_allocated"],
        cores_available: machine["cores_total"] - machine["cores_allocated"],
        status: machine["status"]
      }

    IO.inspect(machine_d, label: "\nCONTD\n")

    {:noreply, machine_d}
  end

  defp compose_key(region_code, address) do
    ProcessRegistry.compose_key(__MODULE__, region_code, address)
  end
end
