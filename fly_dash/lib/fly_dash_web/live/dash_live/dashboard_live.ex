# lib/fly_dash_web/live/dashboard_live.ex
defmodule FlyDashWeb.DashboardLive do
  use FlyDashWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: FlyDashWeb.Endpoint.subscribe("machine_updates")

    # regions = Regions.list_regions_with_machines()
    regions = FlyDash.fetch_regions()

    socket =
      socket
      |> assign(:regions, regions)
      |> assign(:selected_region, nil)
      |> assign(:search_term, "")

    {:ok, socket}
  end

  @impl true
  def handle_info(%{topic: "machine_updates", payload: update}, socket) do
    # Handle real-time machine updates
    updated_regions = update_regions(socket.assigns.regions, update)
    {:noreply, assign(socket, :regions, updated_regions)}
  end

  @impl true
  def handle_event("select_region", %{"region-id" => region_id}, socket) do
    # Handle region selection for detail view
    region = Enum.find(socket.assigns.regions, &(&1["code"] == region_id))
    {:noreply, assign(socket, :selected_region, region)}
  end

  @impl true
  def handle_event("search", %{"term" => term}, socket) do
    # Implement search/filter functionality
    {:noreply, assign(socket, :search_term, term)}
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
