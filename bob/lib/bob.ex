defmodule Bob do
  def hey(input) do
    state =
      String.graphemes(input)
      |> Enum.reduce(%{upper: false, lower: false, other: false, asking: false}, &f/2)

    case state do
      %{upper: false, lower: false, other: false, asking: false} -> "Fine. Be that way!"
      %{upper: true, lower: false, asking: true} -> "Calm down, I know what I'm doing!"
      %{upper: true, lower: false} -> "Whoa, chill out!"
      %{asking: true} -> "Sure."
      _ -> "Whatever."
    end
  end

  defp f(c, state) do
    cond do
      c == "?" -> %{state | asking: true}
      is_lower?(c) -> %{state | lower: true, asking: false}
      is_upper?(c) -> %{state | upper: true, asking: false}
      is_blank?(c) -> state
      true -> %{state | other: true, asking: false}
    end
  end

  defp is_lower?(c), do: c != String.upcase(c)
  defp is_upper?(c), do: c != String.downcase(c)
  defp is_blank?(c), do: "" == String.trim(c)
end
