defmodule FlyDash.Client do
  @base_url "http://localhost:4010/"
  @region_path "/fly-kv/regions/"
  @machines_path "/machines/"
  @machine_path "/machine/"

  def fetch_regions do
    case Req.get(region_url()) do
      {:ok, response} ->
        response.body

      {:error, exception} ->
        raise(exception)
    end
  end

  def fetch_machines_for(region) do
    case Req.get(machines_url(region)) do
      {:ok, response} ->
        response.body

      {:error, exception} ->
        raise(exception)
    end
  end

  def fetch_machine_for(region, machine_id) do
    case Req.get(machine_url(region, machine_id)) do
      {:ok, response} ->
        response.body

      {:error, exception} ->
        raise(exception)
    end
  end

  defp region_url do
    @base_url <> @region_path
  end

  defp machines_url(region) do
    region_url() <> region <> @machines_path
  end

  defp machine_url(region, machine_id) do
    region_url() <> region <> @machine_path <> machine_id
  end
end
