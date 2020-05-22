defmodule RomanNumerals do
  @doc """
  Convert the number to a roman number.
  """
  @spec numeral(pos_integer) :: String.t()
  def numeral(number) do
    number
    |> Integer.digits()
    |> Enum.reverse()
    |> Stream.zip([{"I", "V", "X"}, {"X", "L", "C"}, {"C", "D", "M"}, {"M", "_", "_"}])
    |> Enum.reduce("", fn {x, cs}, acc -> do_numeral(x, cs) <> acc end)
  end

  defp do_numeral(n, {i, _, _}) when n < 4, do: String.duplicate(i, n)
  defp do_numeral(4, {i, v, _}), do: i <> v
  defp do_numeral(n, {i, v, _}) when n < 9, do: v <> String.duplicate(i, n - 5)
  defp do_numeral(9, {i, _, x}), do: i <> x
end
