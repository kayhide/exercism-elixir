defmodule WordCount do
  @doc """
  Count the number of words in the sentence.

  Words are compared case-insensitively.
  """
  @spec count(String.t()) :: map
  def count(sentence) do
    Regex.scan(~r/[-[:alnum:]]+/u, sentence)
    |> Enum.map(fn [x] -> String.downcase x end)
    |> Enum.reduce(%{}, fn x, acc -> acc |> Map.update x, 1, &(&1 + 1) end)
  end
end
