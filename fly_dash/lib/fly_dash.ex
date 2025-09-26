defmodule FlyDash do
  @moduledoc """
  FlyDash keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias FlyDash.Client

  def fetch_regions do
    Client.fetch_regions()
    |> Map.get("data")
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
end
