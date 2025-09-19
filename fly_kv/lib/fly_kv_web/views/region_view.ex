defmodule FlyKvWeb.RegionView do
  # MANUALLY define the render functions that render_many/render_one would provide.
  # This is the cleanest, most direct solution that avoids all dependencies.

  def render("index.json", %{regions: regions}) do
    %{data: Enum.map(regions, &render("region.json", %{region: &1}))}
  end

  def render("metrics_updated.json", %{region_id: region_id, request_response: req_res}) do
    %{
      status: "ok",
      message: "Metrics updated for region #{region_id}",
      request_response: req_res
    }
  end

  def render("region.json", %{region: region}) do
    %{id: region.id, name: region.name, status: region.status}
  end
end
