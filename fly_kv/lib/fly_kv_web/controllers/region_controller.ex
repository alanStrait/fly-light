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

  def allocate(conn, %{"region_code" => region_code, "memory_gb" => memory_gb, "cores" => cores_str}) do
    # TODO: Validate input values
    memory = String.to_integer(memory_gb) * 1_000_000_000
    cores = String.to_integer(cores_str)
    # WIP: refine FlyKv
    case FlyKv.machine_request(region_code, memory, cores) do
      {:ok, machine} ->
        machine = Map.from_struct(machine)
        render(conn, :machine, machine: machine)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, error: reason)
      end
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
