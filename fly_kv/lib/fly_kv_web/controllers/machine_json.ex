defmodule FlyKvWeb.MachineJSON do
  def render("show.json", %{machine: machine}) do
    machine
  end

  def render("index.json", %{machines: machines}) do
    %{
      data: Enum.map(machines, &render("show.json", %{machine: &1}))
    }
  end

  def render("machine.json", %{machine: _machine} = machine_map) do
    %{data: render("show.json", machine_map)}
  end

  def render("error.json", %{error: _error} = error_map) do
    error_map
  end
end
