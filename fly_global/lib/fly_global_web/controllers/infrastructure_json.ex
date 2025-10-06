defmodule FlyGlobalWeb.InfrastructureJSON do
  def render("index.json", %{machines: machines}) do
    %{
      "data" => Enum.map(machines, &render("machine.json", %{machine: &1}))
    }
  end

  def render("machine.json", %{machine: machine}) do
    %{machine: machine}
  end
end
