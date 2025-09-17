defmodule Exercises.GoTour.TreeStream do
  defmodule Tree do
    defstruct value: 0, left: nil, right: nil

    @type t :: %Tree{} # {value = Integer.t(), left = Tree.t(), right = Tree.t()}
  end

  def stream(nil), do: []
  def stream(%Tree{value: v, left: l, right: r}) do
    IO.puts("value #{inspect v} left #{inspect l} right #{inspect r}\n")
    stream(l) ++ [v] ++ stream(r)
  end

  def same(t1, t2) do
    # Run both traversals concurrently
    task1 = Task.async(fn -> stream(t1) end)
    task2 = Task.async(fn -> stream(t2) end)

    # Compare results
    b = Task.await(task1) == Task.await(task2)

    IO.inspect(task1, label: "\nTASK1\n")
    IO.inspect(task2, label: "\nTASK2\n")
    b
  end

  def non_repeating_values(k) when k > 0 do
    values =
      1..100
      |> Enum.shuffle()
      |> Enum.take(k)

    new_tree(nil, values)
  end

  def new_tree(nil, [value|tail]) do
    new_tree(%Tree{left: nil, right: nil, value: value}, tail)
  end

  def new_tree(%Tree{} = parent, [value|[]]) do
    %Tree{parent | value: value}
  end

  def new_tree(%Tree{value: value} = parent, [v|tail]) when v < value do
    IO.puts("v #{v} < value #{value}")
    %Tree{parent | left: new_tree(%Tree{value: v}, tail)}
  end

  def new_tree(%Tree{value: value} = parent, [v|tail]) when v > value do
    IO.puts("v #{v} > value #{value}")
    %Tree{parent | right: new_tree(%Tree{value: v}, tail)}
  end
end
