defmodule Exercises.GoTour.Slices do
  @moduledoc """
  Implement Pic. It should return a slice of length dy, each element of which is a
  slice of dx 8-bit unsigned integers. When you run the program, it will display
  your picture, interpreting the integers as grayscale (well, bluescale) values.

  The choice of image is up to you. Interesting functions include (x+y)/2, x*y, and x^y.

  (You need to use a loop to allocate each []uint8 inside the [][]uint8.)

  (Use uint8(intValue) to convert between types.)
  """

  @doc """
  slices in Go are Arrays that are mutable.  The example that the GO Tour asks
  for here is predicated on a library that renders a bluescale rectangle.

  Elixir's List data structure is quite flexible and easy to put together.  The
  function below does not do anything other than remind me how poerful
  for-comprehensions are and that the Enum module also has great power
  to reshape any enumerable.

  TODO: look for a library similar to `Pic` in the Go example and render
  here.
  """
  def slices(dx, dy) do
    for x <- 1..dx, y <- 1..dy, into: [] do
      x + y - 1
    end
    |> Enum.chunk_every(dx)
  end
end
