defmodule FlyGlobal do
  @moduledoc """
  FlyGlobal provides the context for accessing FlyGlobal business
  behavior.
  """
  alias FlyGlobal.FlyD
  alias FlyGlobal.MachineD
  alias FlyGlobal.FlyKv


  def allocate(region_code, memory_gb, cores, num_candidates) do
    # Obtain randomized list of candidate machines
    result =
      FlyKv.fetch_machine_candidates(region_code, memory_gb, cores, num_candidates)
      # Allocate to first available machine
      |> Enum.reduce_while(%{}, fn %{"machine" => machine} = _arg, acc ->
        case MachineD.allocate_vm(region_code, machine["address"], memory_gb, cores) do
          {:ok, machine} ->
            FlyD.register_change(region_code, machine.address, memory_gb, cores, "available")
            {:halt, machine}

          {:unavailable, _machine} ->
            {:cont, acc}
        end
      end)

    # Return machine summary
    result
  end
end
