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

  # POST /fly-kv/regions/:region_code/machines
  def create(conn, %{"region_code" => region_code} = machine_params) do
    # Logic to create a new machine in the region
    # For now, we'll simulate a created machine
    new_machine =
      Map.merge(%{id: "mach_new", region: region_code, state: "provisioning"}, machine_params)

    conn
    |> put_status(:created)
    |> render(:show, %{machine: new_machine, region_code: region_code})
  end

  # PATCH/PUT /fly-kv/regions/:region_code/machines/:id
  def update(conn, %{"region_code" => region_code, "id" => machine_id} = update_params) do
    # Logic to update a machine
    # Simulating an updated machine
    updated_machine = %{
      id: machine_id,
      region: region_code,
      state: "started",
      updated_fields: update_params
    }

    conn
    |> render(:show, %{machine: updated_machine, region_code: region_code})
  end
end
