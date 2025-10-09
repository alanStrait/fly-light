defmodule FlyDash.Utility do
  @moduledoc false

  def compose_key(%{"region_code" => region_code, "address" => address}) do
    compose_key(region_code, address)
  end

  def compose_key(%{region_code: region_code, address: address}) do
    compose_key(region_code, address)
  end

  def compose_key(region_code, address) do
    region_code <> "::" <> address
  end
end
