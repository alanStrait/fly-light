defmodule Exercises.GoTour.Readers do
  @moduledoc """
  Implement a Reader type that emits an infinite stream of the ASCII character 'A'.
  """
  def stream do
    Stream.cycle([?A])  # Infinite stream of 'A' characters
  end
end
