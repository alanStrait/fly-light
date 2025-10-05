defmodule FlyGlobalWeb.InfrastructureController do
  @moduledoc """
  InfrastructureController orchestrates access to machine resources as well as
  the `consul` `fly-kv` store, thereby simplifying the `fly-proxy`'s responsibilities.
  """
  use FlyGlobalWeb, :controller

  def allocate(conn, %{"region_code" => region_code, "memory_gb" => memory_gb, "cores" => cores}) do
    something = FlyGlobal.allocate(region_code, memory_gb, cores)
  end
end
