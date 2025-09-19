defmodule FlyKvWeb.MachineController do
  use FlyKvWeb, :controller

  # GET /fly-kv/regions/:region_id/machines
  def index(conn, %{"region_id" => region_id}) do
    # Fetch machines for the given region
    machines = [
      %{id: "mach_1", region: region_id, state: "started", cpu: 0.42},
      %{id: "mach_2", region: region_id, state: "stopped", cpu: 0.0}
    ]

    conn
    |> render(:index, %{machines: machines, region_id: region_id})
  end

  # GET /fly-kv/regions/:region_id/machines/:id
  def show(conn, %{"region_id" => region_id, "id" => machine_id}) do
    # Fetch a specific machine
    machine = %{id: machine_id, region: region_id, state: "started", cpu: 0.42, memory_mb: 512}

    conn
    |> render(:show, %{machine: machine, region_id: region_id})
  end

  # POST /fly-kv/regions/:region_id/machines
  def create(conn, %{"region_id" => region_id} = machine_params) do
    # Logic to create a new machine in the region
    # For now, we'll simulate a created machine
    new_machine = Map.merge(%{id: "mach_new", region: region_id, state: "provisioning"}, machine_params)

    conn
    |> put_status(:created)
    |> render(:show, %{machine: new_machine, region_id: region_id})
  end

  # PATCH/PUT /fly-kv/regions/:region_id/machines/:id
  def update(conn, %{"region_id" => region_id, "id" => machine_id} = update_params) do
    # Logic to update a machine
    # Simulating an updated machine
    updated_machine = %{id: machine_id, region: region_id, state: "started", updated_fields: update_params}

    conn
    |> render(:show, %{machine: updated_machine, region_id: region_id})
  end
end
