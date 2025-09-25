defmodule FlyKv do
  @moduledoc """
  FlyKv provides the context for interacting with a local, in-memory
  key-value store that manages by region the status of machines known
  to Flylight.

  All key-value data access should go through this context module.
  """
  alias FlyKv.Store

  @doc """
  list_regions returns all regions.
  """
  def list_regions do
    Store.list_regions()
  end

  @doc """
  machines_for returns all machines for this region.
  """
  def machines_for(region_code) do
    Store.machines_for_region(region_code)
  end

  @doc """
  machine_for returns one specific machine.
  """
  def machine_for(region_code, machine_address) do
    Store.machine_for_region(region_code, machine_address)
  end

  @doc """
  machine_request will allocate a VM from a battery of servers known
  to a given region.

  `region_code`: three character code identifying region.
  `memory_gb`: memory, in gigabytes, being requested
  `cores`:  number of cores being requested
  """
  @gb_multiplier 1000 * 1000 * 1000
  @spec machine_request(binary(), integer(), integer()) :: {:ok, map()} | {:error, binary()}
  def machine_request(region_code, memory_gb, cores_needed) do
    memory = memory_gb * @gb_multiplier
    case Store.machine_request(region_code, memory, cores_needed) do
      nil ->
        {:error, "Unable to allocate VM for #{region_code}"}

      machine ->
        {:ok, machine}
    end
  end
end
