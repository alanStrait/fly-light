defmodule Exercises.GoTour.Fibonacci do
  @moduledoc """
  fibonacci returns the Fibonacci number in the sequence at the position
  passed in.

  This was not an exercise in the Go Tour, but cam up and is a fun one
  to implement in both Eixir and Go.

  This implementation is different than the Go implementation in that
  it returns the value for a specific position in the Fibonacci sequence,
  where the Go function lists the Fibonacci sequence for a sequence of 10.
  """

  def fibonacci(0), do: value(0)
  def fibonacci(1), do: value(1)
  def fibonacci(2), do: value(1)

  def fibonacci(position) when position >= 2 do
    value(position - 1) + value(position - 2)
  end

  defp value(0), do: 0
  defp value(1), do: 1
  defp value(n), do: value(n - 1) + value(n - 2)
end
