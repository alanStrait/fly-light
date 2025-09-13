defmodule Exercises.GoTour do
  @moduledoc """
  `GoTour` is the context module to access solutions to problems presented
  in the `go.dev/tour`, to be created in concert with their corresponding
  Go solutions in the `go-scratch/exercises/go_tour/` modules.
  """
  alias Exercises.GoTour.{
    LoopsAndFunctions, Slices, Fibonacci, Stringers, MyErrors
  }

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

  @doc """
  stringers is an example of an non-explicit interface where by implementing
  an expected function in Go, you get the benefit of the the Interface
  (need better words).  In Elixir, we use pattern matching with @type
  to accomplish similar capability.
  """
  def stringers({_a, _b, _c, _d} = ip_tuple) do
    Stringers.to_string(ip_tuple)
  end

  @doc """
  my_errors a negative (complex) number will result in an error.
  """
  def my_errors(radicand) when radicand < 0 do
    {:error, str} = MyErrors.sqrt(radicand)
    IO.puts("Error string: #{inspect str}")
  end

  def my_errors(radicand) do
    {:ok, value} = MyErrors.sqrt(radicand)
    IO.puts("sqrt is #{inspect value}")
  end
end
