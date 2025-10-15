defmodule FlyGlobal.FlyKv.Client do
  @base_url "http://localhost:4010/"
  @region_path "/fly-kv/regions/"
  @machines_path "/machines/"
  @machine_candidates_path "/machine/candidates"

  alias FlyGlobal.FlyD

  def fetch_regions do
    case Req.get(region_url()) do
      {:ok, response} ->
        response.body

      {:error, exception} ->
        raise(exception)
    end
  end

  def fetch_machine_candidates(region_code, memory_gb, cores, num_candidates) do
    query_params = [memory_gb: memory_gb, cores: cores, num_candidates: num_candidates]
    case Req.get(candidate_url(region_code), params: query_params) do
      {:ok, response} ->
        response.body

      {:error, reason} ->
        raise(reason)
    end
  end

  def patch_machine(region_code, address, %FlyD{} = flyd) do
    flyd_map = Map.from_struct(flyd)
    case Req.patch(machine_url(region_code, address), json: flyd_map) do
      {:ok, response} ->
        response.body

      {:error, reason} ->
        raise(reason)
    end
  end

  defp candidate_url(region_code) do
    region_url() <> region_code <> @machine_candidates_path
  end

  defp machine_url(region_code, address) do
    region_url() <> region_code <> @machines_path <> address
  end

  defp region_url do
    @base_url <> @region_path
  end

end
