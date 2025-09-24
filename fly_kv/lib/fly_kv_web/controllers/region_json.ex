defmodule FlyKvWeb.RegionJSON do
  # If you're using Phoenix 1.7+, you'll want to use the embed_templates macro
  # for function components, but for JSON views we typically define functions directly

  # Render a single region
  def render("show.json", %{region: region}) do
    %{
      code: region.code,
      location: region.location,
      status: region.status
    }
  end

  # Render a list of regions (for index action)
  def render("index.json", %{regions: regions}) do
    %{
      data: Enum.map(regions, &render("show.json", %{region: &1}))
    }
  end

  # You can add other render patterns as needed
  def render("region.json", %{region: region}) do
    %{data: render("show.json", %{region: region})}
  end

  # Handle errors or other response types
  def render("error.json", %{error: error}) do
    %{error: error}
  end
end
