defmodule Exercises.GoTour do
  @moduledoc """
  `GoTour` is the context module to access solutions to problems presented
  in the `go.dev/tour`, to be created in concert with their corresponding
  Go solutions in the `go-scratch/exercises/go_tour/` modules.
  """
  alias Exercises.GoTour.{LoopsAndFunctions, Slices, Fibonacci}

  @doc """
  loops_and_functions uses a seek function to demonstrate looping in Go and,
  now, here in Elixir.
  """
  def loops_and_functions do
    IO.puts("Hello from loops and functions")
    LoopsAndFunctions.sqrt(8)
  end

  @doc """
  slices is not complete.
  Wanted: an Elixir library like Pic in Go to complete this exercise.
  """
  def slices do
    Slices.slices(3, 3)
  end

  @doc """
  fibonacci returns the Fibonacci number at the position in the sequence
  passed in.
  """
  def fibonacci(position) do
    IO.puts("pos #{position}")
    Fibonacci.calculate(position)
  end
end
