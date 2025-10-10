defmodule FlyDash.KvSubscriber do
  alias Phoenix.PubSub
  import FlyDash.Utility
  require Logger
  use GenServer

  @fly_kv_node :"fly_kv@127.0.0.1"
  @topic "machine:changes"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, %{}, {:continue, %{init: :state}}}
  end

  def handle_continue(_continue_arg, state) do
    case Node.connect(@fly_kv_node) do
      true ->
        :ok = Phoenix.PubSub.subscribe(Flylight.PubSub, @topic)

        # Test message
        test_payload = %{
          event: :subscription_test,
          region_code: "test",
          machine_address: "test",
          timestamp: DateTime.utc_now(),
          metadata: %{test: true}
        }

        Phoenix.PubSub.broadcast(Flylight.PubSub, @topic, test_payload)
        IO.puts("Sent test message to topic: #{@topic}")

        {:ok, %{connected: true}}

      false ->
        IO.puts("Failed to connect to #{@fly_kv_node}")
        Process.send_after(self(), :reconnect, 5000)
        {:ok, %{connected: false}}
    end

    {:noreply, state}
  end

  def handle_info(:reconnect, state) do
    case Node.connect(@fly_kv_node) do
      true ->
        Phoenix.PubSub.subscribe(Flylight.PubSub, @topic)
        IO.puts("Reconnected and subscribed to topic #{@topic}")
        {:noreply, %{state | connected: true}}

      false ->
        Process.send_after(self(), :reconnect, 5000)
        {:noreply, state}
    end
  end

  def handle_info(
        %{
          event: :update,
          region_code: region_code,
          machine_address: machine_address,
          metadata: metadata
        } = message,
        state
      ) do
    Logger.info(
      "#{message.timestamp} [update] #{region_code} #{machine_address} #{metadata.memory_allocated} #{metadata.cores_allocated}"
    )

    broadcast_update(message)
    {:noreply, state}
  end

  def handle_info(message, state) do
    # Clear mailbox to prevent memory leak
    Logger.warning("Unexpeected message #{inspect(message)}")
    {:noreply, state}
  end

  defp broadcast_update(%{region_code: region_code, machine_address: address, metadata: metadata}) do
    message =
      %{
        "key" => compose_key(region_code, address),
        "region_code" => region_code,
        "address" => address,
        "memory_allocated" => metadata.memory_allocated,
        "cores_allocated" => metadata.cores_allocated,
        "status" => "updating",
        "updated_at" => to_string(metadata.updated_at)
      }

    PubSub.broadcast(Flylight.PubSub, "dashboard_updates", {:dashboard_data_updated, message})
  end
end
