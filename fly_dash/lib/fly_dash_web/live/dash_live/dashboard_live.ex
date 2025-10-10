# lib/fly_dash_web/live/dashboard_live.ex
defmodule FlyDashWeb.DashboardLive do
  use FlyDashWeb, :live_view

  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(Flylight.PubSub, "dashboard_updates")

    # regions = Regions.list_regions_with_machines()
    regions = FlyDash.fetch_regions()

    socket =
      socket
      |> assign(:regions, regions)
      # |> assign(:selected_region, nil)
      |> assign(:selected_region_code, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_region", %{"region-id" => region_code}, socket) do
    # Handle region selection for detail view
    region = Enum.find(socket.assigns.regions, &(&1["code"] == region_code))
    IO.inspect(region, label: "\nEGION\n")
    IO.inspect(region_code, label: "\nEGION ID\t")
    {:noreply, assign(socket, :selected_region_code, region_code)}
  end

  @impl true
  def handle_info({:dashboard_data_updated, data}, socket) do
    %{"region_code" => region_code, "key" => key} = data

    # Directly transform the regions list - no update_in needed
    updated_regions =
      Enum.map(socket.assigns.regions, fn region ->
        if region["code"] == region_code do
          updated_machines =
            Enum.map(region["machines"], fn machine ->
              if machine["key"] == key do
                %{
                  machine
                  | "cores_allocated" => data["cores_allocated"],
                    "memory_allocated" => data["memory_allocated"],
                    "status" => data["status"],
                    "updated_at" => data["updated_at"]
                }
              else
                machine
              end
            end)

          %{region | "machines" => updated_machines}
        else
          region
        end
      end)

    {:noreply, assign(socket, :regions, updated_regions)}
  end

  defp get_selected_region(socket) do
    case socket.assigns do
      %{selected_region_code: code} when not is_nil(code) ->
        Enum.find(socket.assigns.regions, &(&1["code"] == code))

      _ ->
        nil
    end

    if socket.assigns.selected_region_code do
      Enum.find(socket.assigns.regions, &(&1["code"] == socket.assigns.selected_region_code))
    end
  end

  defp update_regions(_regions, _machine_update) do
    # Logic to update specific machine status across regions
    # This maintains immutability while allowing real-time updates
  end

  defp status_color(status) do
    case status do
      "online" -> "text-[#10B981]"
      "offline" -> "text-[#EF4444]"
      "maintenance" -> "text-[#F59E0B]"
      _ -> "text-[#A0A0A0]"
    end
  end

  defp machine_status_color(status) do
    case status do
      "running" -> "text-[#10B981]"
      "stopped" -> "text-[#EF4444]"
      "starting" -> "text-[#F59E0B]"
      "updating" -> "text-[#8B5CF6]"
      _ -> "text-[#A0A0A0]"
    end
  end

  defp formatted_time(time) do
    {:ok, dt, 0} = DateTime.from_iso8601(time)
    Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S")
  end

  defp extract_name(input) when is_binary(input) do
    cond do
      # Match IPv4 address (e.g., 192.168.1.1)
      Regex.match?(~r/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/, input) ->
        input

      # Match hostname with period (e.g., consul-node-12.other)
      # Regex.match?(~r/^[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/, input) ->
      Regex.match?(~r/^[a-zA-Z0-9-]+/, input) ->
        String.split(input, "\.") |> hd()

      # Default case (no period or other format)
      true ->
        input
    end
  end

  defp memory_gb(memory) do
    memory / 1_000_000_000
  end
end
