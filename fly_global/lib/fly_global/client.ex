defmodule FlyGlobal.Client do
  @base_url "http://localhost:4010/"
  @region_path "/fly-kv/regions/"
  @machines_path "/machines/"

  alias FlyGlobal.FlyD

  def fetch_regions do
    case Req.get(region_url()) do
      {:ok, response} ->
        response.body

      {:error, exception} ->
        raise(exception)
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

  defp machine_url(region_code, address) do
    region_url() <> region_code <> @machines_path <> address
  end

  defp region_url do
    @base_url <> @region_path
  end
end
