defmodule FlyDash.KvSubscriber do
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
        %{event: _event, region_code: region_code, machine_address: machine_address} = message,
        state
      ) do
    IO.inspect(message, label: "\n\nReceived KV change\n\n")
    handle_update(region_code, machine_address, message.metadata)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    # TODO remove function
    IO.inspect(msg, label: "\n\nHANDLE_INFO UNEXPECTED MSG\n\n")
    {:noreply, state}
  end

  defp handle_update(region_code, machine_address, metadata) do
    # TODO: update LiveView
    IO.puts("Update: region #{region_code}, machine #{machine_address}")
    IO.inspect(metadata, label: "Metadata")
    # Your update handling logic here
  end
end
