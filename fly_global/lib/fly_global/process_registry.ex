defmodule FlyGlobal.ProcessRegistry do
  @moduledoc """
  ProcessRegistry is lifted from Sasa Juric's "Elixir in Action, Second Edition"
  as it provides a convenient way to register OTP-compliant processes
  such as GenServer and Supervisor that are uniquely identified.
  For our purposes, the processes to be registered are representative of
  datacenter infrastructure such as servers.
  """
  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def via_tuple(module, key) do
    {:via, Registry, {module, key}}
  end

  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end

  def compose_key(module, region_code, %{"address" => address}) do
    compose_key(module, region_code, address)
  end

  def compose_key(module, region_code, address) do
    to_string(module) <> "::" <> region_code <> "::" <> address
  end
end
