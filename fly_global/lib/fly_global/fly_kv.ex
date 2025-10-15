defmodule FlyGlobal.FlyKv do
  alias FlyGlobal.FlyKv.Client

  @doc """
  fetch_regions returns and their machines for populating `MachineD`
  and `FlyD` `GenServer`s with "consul" data.
  """
  def fetch_regions do
    Client.fetch_regions()
    |> Map.get("data")
  end

  def fetch_machine_candidates(region_code, memory_gb, cores, num_candidates) do
    Client.fetch_machine_candidates(region_code, memory_gb, cores, num_candidates)
    |> Map.get("data")
  end
end
