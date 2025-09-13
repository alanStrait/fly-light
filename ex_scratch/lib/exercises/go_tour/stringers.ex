defmodule Exercises.GoTour.Stringers do
  @moduledoc """
  Stringers, in Go, represent modules that implement `String()`.  This exercise
  format data defined as a custom type, IPAddr.
  """
  @type ip_tuple :: {byte(), byte(), byte(), byte()}

  @spec to_string(ip_tuple()) :: String.t()
  def to_string({a, b, c, d}) do
    "#{a}.#{b}.#{c}.#{d}"
  end
end
