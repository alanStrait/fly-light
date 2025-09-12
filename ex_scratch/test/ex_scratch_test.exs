defmodule ExScratchTest do
  use ExUnit.Case
  doctest ExScratch

  test "greets the world" do
    assert ExScratch.hello() == :world
  end
end
