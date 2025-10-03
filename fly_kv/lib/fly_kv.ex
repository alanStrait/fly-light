defmodule FlyKv do
  @moduledoc """
  FlyKv provides the context for interacting with a local, in-memory
  key-value store that manages by region the status of machines known
  to Flylight.

  All key-value data access should go through this context module.
  """
  alias FlyKv.Store

  @gb_multiplier 1000 * 1000 * 1000

  @doc """
  list_regions returns all regions.
  """
  def list_regions do
    Store.list_regions()
  end

  def fetch_regions_with_machines do
    Store.fetch_regions_with_machines()
  end

  @doc """
  machine_candidates_for returns the `num_candidates` machines for
  the `region_code` that can meet the `memory_gb` and `cores`
  requirements.
  """
  def machine_candidates_for(region_code, memory_gb, cores, num_candidates)
      when is_binary(memory_gb) or is_binary(cores) or is_binary(num_candidates) do
    machine_candidates_for(
      region_code,
      String.to_integer(memory_gb),
      String.to_integer(cores),
      String.to_integer(num_candidates)
    )
  end

  def machine_candidates_for(region_code, memory_gb, cores, num_candidates)
      when is_integer(memory_gb) and is_integer(cores) do
    memory = memory_gb * @gb_multiplier
    Store.machine_candidates_for(region_code, memory, cores, num_candidates)
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

  @spec update_machine(binary(), binary(), integer(), integer(), binary()) ::
          {:ok, FlyKv.Machine.t()} | {:error, binary()}
  def update_machine(region_code, address, memory_allocated_gb, cores_allocated, status) do
    memory_allocated = memory_allocated_gb * @gb_multiplier
    Store.update_machine(region_code, address, memory_allocated, cores_allocated, status)
  end
end
