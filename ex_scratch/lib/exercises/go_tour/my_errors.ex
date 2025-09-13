defmodule Exercises.GoTour.MyErrors do
  @moduledoc """
  MyErrors in Elixir we use tuples with an atom indicating `:ok` or `:error`
  along with the return value or error message.
  """
  @type error :: {:error, String.t()}

  @spec sqrt(pos_integer()) :: {:ok, tuple()} | error()
  def sqrt(radicand) when radicand < 0 do
    {:error, "cannot sqrt negative number #{radicand}"}
  end

  def sqrt(radicand) do
    Enum.reduce_while(1..10, {1, 1}, fn _i, acc ->
      {prior, current} = acc
      current = newtons_method(current, radicand)
      diff = abs(prior - current)
      prior = current

      if diff < 0.002 do
        {:halt, {:ok, current}}
      else
        {:cont, {prior, current}}
      end
    end)
  end

  def newtons_method(current, radicand) do
    abs(current - (current * current - radicand) / (2 * current))
  end
end
