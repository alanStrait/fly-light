defmodule Exercises.GoTour.Rot13Reader do
  def decode(string) do
    string
    |> String.to_charlist()
    |> Enum.map(&rot13/1)
    |> List.to_string()
  end

  defp rot13(char) when char in ?a..?z, do: ?a + rem(char - ?a + 13, 26)
  defp rot13(char) when char in ?A..?Z, do: ?A + rem(char - ?A + 13, 26)
  defp rot13(char), do: char
end
