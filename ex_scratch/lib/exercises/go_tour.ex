defmodule Exercises.GoTour do
  @moduledoc """
  `GoTour` is the context module to access solutions to problems presented
  in the `go.dev/tour`, to be created in concert with their corresponding
  Go solutions in the `go-scratch/exercises/go_tour/` modules.
  """
  alias Exercises.GoTour
  alias GoTour.LoopsAndFunctions
  def loops_and_functions do
    IO.puts("Hello from loops and functions")
    LoopsAndFunctions.sqrt(8)
  end
end
