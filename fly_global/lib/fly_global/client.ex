defmodule FlyGlobal.Client do
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

  defp region_url do
    @base_url <> @region_path
  end
end
