defmodule WordCount do
  @doc """
  Count the number of words in the sentence.

  Words are compared case-insensitively.
  """
  @spec count(String.t()) :: map
  def count(sentence) do
    Regex.scan(~r/[-[:alnum:]]+/u, sentence)
    |> Enum.frequencies_by(fn [x] -> String.downcase(x) end)
  end
end
