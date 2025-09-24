defmodule FlyKvWeb.MachineController do
  use FlyKvWeb, :controller

  # GET /fly-kv/regions/:region_code/machines
  def index(conn, %{"region_code" => region_code}) do
    # Fetch machines for the given region
    machines =
      region_code
      |> FlyKv.machines_for()
      |> Enum.map(fn {_key, value} -> Map.from_struct(value) end)

    conn
    |> render(:index, %{machines: machines, region_code: region_code})
  end

  # GET /fly-kv/regions/:region_code/machines/:id
  def show(conn, %{"region_code" => region_code, "id" => machine_id}) do
    # Fetch a specific machine
    machine = %{id: machine_id, region: region_code, state: "started", cpu: 0.42, memory_mb: 512}

    conn
    |> render(:show, %{machine: machine, region_code: region_code})
  end
end
