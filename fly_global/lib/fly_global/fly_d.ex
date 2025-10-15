defmodule FlyGlobal.FlyD do
  use GenServer

  alias FlyGlobal.ProcessRegistry
  alias FlyGlobal.FlyKv.Client
  require Logger

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
    fly_d =
      %__MODULE__{
        region_code: state.region_code,
        address: state.address,
        memory_allocated_gb: memory_gb,
        cores_allocated: cores,
        status: status
      }

    state_prime =
      update_in(state[:queue], fn queue -> [fly_d | queue] end)

    {:noreply, state_prime}
  end

  @impl true
  def init(init_args) do
    {:ok, %{}, {:continue, init_args}}
  end

  @loop_interval 15_000
  @impl true
  def handle_continue({region_code, %{"address" => address}}, _state) do
    fly_d =
      %{
        region_code: region_code,
        address: address,
        queue: [],
        loop_ref: nil
      }

    loop_ref = Process.send_after(self(), :push_flyd_queue_to_store, @loop_interval)

    {:noreply, %{fly_d | loop_ref: loop_ref}}
  end

  @impl true
  def handle_info(:push_flyd_queue_to_store, state) do
    state_prime = push_queue(state)
    loop_ref = Process.send_after(self(), :push_flyd_queue_to_store, @loop_interval)
    {:noreply, %{state_prime | loop_ref: loop_ref}}
  end

  def push_queue(state) do
    state_prime =
      case conflate(state.queue) do
        [] -> state

        flyd ->
          case Client.patch_machine(state.region_code, state.address, flyd) do

            {:ok, body} ->
              Logger.info("Successfully patched #{state.region_code} #{state.address} with #{inspect body}")
              %{state | queue: []}

            {:error, reason} ->
              Logger.info("Error Patching #{state.region_code} #{state.address} due to #{inspect reason}")
              state

            %{"message" => message} ->
              Logger.info("push_queue message: #{inspect message}")
              %{state | queue: []}

          end
      end

    state_prime
  end

  defp conflate([]), do: []
  defp conflate([flyd|[]]), do: flyd
  defp conflate(flyd_list) do
    flyd_list
    |> Enum.reverse()
    |> Enum.reduce(fn flyd, acc ->
      %__MODULE__{
        acc |
        memory_allocated_gb: acc.memory_allocated_gb + flyd.memory_allocated_gb,
        cores_allocated: acc.cores_allocated + flyd.cores_allocated,
        status: flyd.status
      }
    end)
  end
end
