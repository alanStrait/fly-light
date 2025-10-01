defmodule FlyGlobal do
  @moduledoc """
  FlyGlobal provides the context for accessing FlyGlobal business
  behavior.
  """
  alias FlyGlobal.Client

  def fetch_regions do
    Client.fetch_regions()
    |> Map.get("data")
  end
end
