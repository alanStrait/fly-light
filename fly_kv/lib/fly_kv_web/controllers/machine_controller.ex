defmodule FlyKvWeb.MachineController do
  use FlyKvWeb, :controller

  # GET /fly-kv/regions/:region_code/machines
  def index(conn, %{"region_code" => region_code}) do
    # Fetch machines for the given region
    machines =
      region_code
      |> FlyKv.machines_for()
      |> Enum.map(fn {_key, value} -> value end)

    conn
    |> render(:index, %{machines: machines, region_code: region_code})
  end

  # GET /fly-kv/regions/:region_code/machines/:id
  def show(conn, %{"region_code" => region_code, "id" => machine_address}) do
    # Fetch a specific machine
    machine = FlyKv.machine_for(region_code, machine_address)

    conn
    |> render(:show, %{machine: machine, region_code: region_code})
  end

  def update(
        conn,
        %{
          "region_code" => region_code,
          "id" => address,
          "memory_allocated_gb" => memory_allocated_gb,
          "cores_allocated" => cores_allocated,
          "status" => status
        }
      ) do
    case FlyKv.update_machine(region_code, address, memory_allocated_gb, cores_allocated, status) do
      {:ok, machine} -> #{:ok, machine}
        conn |> render(:show, %{machine: machine, region_code: region_code})

      {:error, reason} -> #{:error, reason}
        conn |> render(:error, error: reason)
    end

  end
end
