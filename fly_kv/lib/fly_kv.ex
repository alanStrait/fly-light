defmodule FlyKv do
  @moduledoc """
  FlyKv provides the context for interacting with a local, in-memory
  key value store that manages status of machines known to Flylight
  by region.

  All key-value data access should go through this context module.
  """

  @doc """
  list_regions returns all regions.
  """
  def list_regions do
    []
  end

  @doc """
  machines_for returns all machines for this region.
  """
  def machines_for(region_id) do
    ""
  end

  @doc """
  machine_for returns one specific machine.
  """
  def machine_for(region_id, machine_id) do
    ""
  end
end
