defmodule FlyKvWeb.MachineView do
  # Same approach: manually map the data.

  def render("index.json", %{machines: machines, region_id: region_id}) do
    %{
      region_id: region_id,
      data: Enum.map(machines, &render("machine.json", %{machine: &1}))
    }
  end

  def render("show.json", %{machine: machine, region_id: _region_id}) do
    %{data: render("machine.json", %{machine: machine})}
  end

  def render("machine.json", %{machine: machine}) do
    base_map = %{
      id: machine.id,
      region: machine.region,
      state: machine.state,
      cpu: machine.cpu,
      memory_mb: machine.memory_mb
    }
    # Handle the simulated 'updated_fields'
    Map.merge(base_map, Map.get(machine, :updated_fields, %{}))
  end
end
