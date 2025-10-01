defmodule FlyGlobal.FlyD do
  use GenServer

  alias FlyGlobal.ProcessRegistry

  defstruct [
    :region_code,
    :address,
    :memory_allocated_gb,
    :cores_allocated,
    :status
  ]

  @type t :: %__MODULE__{
    region_code: String.t(),
    address: String.t(),
    memory_allocated_gb: integer(),
    cores_allocated: integer(),
    status: String.t()
  }

  # @type s :: %{
  #   region_code: String.t(),
  #   address: String.t(),
  #   queue: list(t())
  # }

  # Client API

  def register_change(region_code, address, memory_gb, cores, status) do
    key = compose_key(region_code, address)
    GenServer.cast(via_tuple(key), {:register_change, memory_gb, cores, status})
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

  defp compose_key(region_code, address) do
    ProcessRegistry.compose_key(__MODULE__, region_code, address)
  end

  # Server callbacks

  @impl true
  def handle_cast({:register_change, memory_gb, cores, status}, state) do
    IO.puts("\nHANDLE_CAST\n")
    fly_d =
      %__MODULE__{
        region_code: state.region_code,
        address: state.address,
        memory_allocated_gb: memory_gb,
        cores_allocated: cores,
        status: status
      }

    state_prime =
      update_in(state[:queue], fn queue -> [fly_d| queue] end)
      |> IO.inspect(label: "\nHERE\n")

    {:noreply, state_prime}
  end

  @impl true
  def init(init_args) do
    {:ok, %{}, {:continue, init_args}}
  end

  @impl true
  def handle_continue({region_code, %{"address" => address} = machine}, _state) do
    fly_d =
      %{
        region_code: region_code,
        address: address,
        queue: []
      }
      |> IO.inspect(label: "\nCONTD\n")

    {:noreply, fly_d}
  end
end
