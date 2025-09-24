defmodule FlyKvWeb.RegionController do
  use FlyKvWeb, :controller

  # GET /fly-kv/regions
  def index(conn, _params) do
    regions =
      FlyKv.list_regions()
      |> Enum.map(fn {_key, region} -> Map.from_struct(region) end)

    conn
    |> render(:index, regions: regions)
  end

  # PUT /fly-kv/regions/:region_code/metrics
  def update_metrics(conn, %{"region_code" => region_code, "request_response" => request_response}) do
    # Your logic to process the request-response metrics for the region would go here.
    # For now, we'll just echo it back.

    conn
    |> put_status(:ok)
    |> render(:metrics_updated, %{region_code: region_code, request_response: request_response})
  end
end
