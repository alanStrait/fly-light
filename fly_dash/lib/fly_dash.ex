defmodule FlyDash do
  @moduledoc """
  FlyDash keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias FlyDash.Client

  import FlyDash.Utility

  def fetch_regions do
    Client.fetch_regions()
    |> Map.get("data")
    |> Enum.map(&flatten_and_add_key/1)
    |> Enum.sort_by(fn region ->
      machine_count = length(region["machines"])
      {-machine_count, region["code"]}
    end)
  end

  def fetch_machines_for(region) do
    Client.fetch_machines_for(region)
  end

  def fetch_machine_for(region, machine_id) do
    Client.fetch_machine_for(region, machine_id)
  end

  defp flatten_and_add_key(%{"machines" => []} = region), do: region

  defp flatten_and_add_key(region) do
    machines =
      region["machines"]
      |> Enum.map(fn machine ->
        %{
          "key" => compose_key(machine),
          "region_code" => machine["region_code"],
          "address" => machine["address"],
          "cores_allocated" => machine["cores_allocated"],
          "cores_total" => machine["cores_total"],
          "memory_allocated" => machine["memory_allocated"],
          "memory_total" => machine["memory_total"],
          "status" => machine["status"],
          "updated_at" => machine["updated_at"]
        }
      end)

    %{region | "machines" => machines}
  end
end
