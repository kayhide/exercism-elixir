defmodule Bob do
  def hey(input) do
    state =
      String.graphemes(input)
      |> Enum.reduce(%{upper: false, lower: false, digit: false, asking: false}, &f/2)

    case state do
      %{upper: false, lower: false, digit: false, asking: false} -> "Fine. Be that way!"
      %{upper: true, lower: false, asking: true} -> "Calm down, I know what I'm doing!"
      %{upper: true, lower: false} -> "Whoa, chill out!"
      %{asking: true} -> "Sure."
      _ -> "Whatever."
    end
  end

  defp f(c, state) do
    cond do
      String.match?(c, ~r/[[:lower:]]/) -> %{state | lower: true, asking: false}
      String.match?(c, ~r/[[:upper:]]/) -> %{state | upper: true, asking: false}
      String.match?(c, ~r/[[:digit:]]/) -> %{state | digit: true, asking: false}
      String.match?(c, ~r/\?/) -> %{state | asking: true}
      true -> state
    end
  end
end
