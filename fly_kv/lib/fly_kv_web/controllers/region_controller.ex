defmodule FlyKvWeb.RegionController do
  use FlyKvWeb, :controller

  # GET /fly-kv/regions
  def index(conn, _params) do
    # In a real app, you'd fetch this from a database or service.
    regions = [
      %{id: "ord", name: "Chicago", status: "online"},
      %{id: "iad", name: "Ashburn", status: "online"},
      %{id: "sjc", name: "San Jose", status: "degraded"}
    ]

    conn
    |> render(:index, regions: regions)
  end

  # PUT /fly-kv/regions/:region_id/metrics
  def update_metrics(conn, %{"region_id" => region_id, "request_response" => request_response}) do
    # Your logic to process the request-response metrics for the region would go here.
    # For now, we'll just echo it back.

    conn
    |> put_status(:ok)
    |> render(:metrics_updated, %{region_id: region_id, request_response: request_response})
  end
end
