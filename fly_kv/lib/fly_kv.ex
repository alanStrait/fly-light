defmodule FlyKv do
  @moduledoc """
  FlyKv provides the context for interacting with a local, in-memory
  key value store that manages status of machines known to Flylight
  by region.

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
  def machine_for(region_code, machine_key) do
    Store.machine_for_region(region_code, machine_key)
  end

  def machine_request(region_code, memory_needed, cores_needed) do
    Store.machine_request(region_code, memory_needed, cores_needed)
  end
end
