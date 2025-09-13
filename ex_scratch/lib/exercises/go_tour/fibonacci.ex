defmodule Exercises.GoTour.Fibonacci do
  @moduledoc """
  fibonacci returns the Fibonacci number in the sequence at the position
  passed in.

  This was not an exercise in the Go Tour, but cam up and is a fun one
  to implement in both Eixir and Go.

  This implementation is different than the Go implementation in that
  it returns the value for a specific position in the Fibonacci sequence,
  where the Go function lists the Fibonacci sequence for a sequence of 10.

  Fibonacci has been enhanced to keep a map of computed values by way of `Agent`,
  providing for a simple cache because we do allow requests for arbitrary
  Fibonacci values.
  """
  use Agent

  def start_link(_state) do
    Agent.start_link(fn -> %{0 => 0, 1 => 1} end, name: __MODULE__)
  end

  def calculate(0), do: calculate_uncached(0)
  def calculate(1), do: calculate_uncached(1)
  def calculate(2), do: calculate_uncached(1)

  def calculate(position) when position >= 2 do
    case Agent.get(__MODULE__, &Map.get(&1, position)) do
      nil ->
        result = calculate_uncached(position)
        Agent.update(__MODULE__, &Map.put(&1, position, result))
        result

      cached_result ->
        cached_result
    end

    # calculate_uncached(position - 1) + calculate_uncached(position - 2)
  end

  defp calculate_uncached(0), do: 0
  defp calculate_uncached(1), do: 1
  defp calculate_uncached(n), do: calculate_uncached(n - 1) + calculate_uncached(n - 2)

  def cache_size do
    Agent.get(__MODULE__, &map_size/1)
  end

  def clear_cache do
    Agent.update(__MODULE__, fn _ -> %{0 => 0, 1 => 1} end)
  end
end
