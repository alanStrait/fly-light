defmodule FlyKvWeb.RegionJSON do
  alias FlyKvWeb.MachineJSON

  # Render a single region
  def render("show.json", %{region: region}) do
    %{
      code: region.code,
      location: region.location,
      status: region.status,
      machines: region.machines
    }
  end

  # Render a list of regions (for index action)
  def render("index.json", %{regions: regions}) do
    %{
      data: Enum.map(regions, &render("show.json", %{region: &1}))
    }
  end

  def render("machine.json", %{machine: machine}) do
    %{data: MachineJSON.render("show.json", %{machine: machine})}
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
