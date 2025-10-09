defmodule FlyKv.Notifications do
  @moduledoc """
  Notifications broadcasts changes to those listening on
  shared PubSub channel.
  """
  use GenServer

  @topic "machine:changes"

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def broadcast_update(
        region_code,
        machine_address,
        memory_allocated,
        cores_allocated,
        status,
        updated_at
      ) do

    GenServer.cast(
      __MODULE__,
      {:update, region_code, machine_address,
       %{
         memory_allocated: memory_allocated,
         cores_allocated: cores_allocated,
         status: status,
         updated_at: updated_at
       }}
    )
  end

  # Server callbacks

  @impl true
  def init(_init_arg) do
    Phoenix.PubSub.subscribe(Flylight.PubSub, @topic)

    {:ok, %{update_count: 0}}
  end

  @impl true
  def handle_cast({:update, region_code, machine_address, metadata}, state) do
    broadcast_change(:update, region_code, machine_address, metadata)

    {:noreply, %{state | update_count: state.update_count + 1}}
  end

  @impl true
  def handle_info(_all_msgs, state) do
    # Pop messages to prevent memory leak

    {:noreply, state}
  end

  def broadcast_change(event_type, region_code, machine_address, metadata) do
    message =
      %{
        event: event_type,
        region_code: region_code,
        machine_address: machine_address,
        timestamp: metadata.updated_at,
        metadata: metadata
      }

    case Phoenix.PubSub.broadcast(Flylight.PubSub, @topic, message) do
      :ok -> IO.puts("\nMessage SUCCESSFULLY broadcast\n")

      {:error, term} ->
        IO.puts("\nError broadcasting msg #{inspect term}\n")
    end

    :ok
  end
end
