defmodule BeerSong do
  @doc """
  Get a single verse of the beer song
  """
  @spec verse(integer) :: String.t()
  def verse(number) do
    first_line(number) <> second_line(number)
  end

  defp bottles(number) do
    case number do
      0 -> "no more bottles"
      1 -> "1 bottle"
      _ -> "#{number} bottles"
    end
  end

  defp one(number) do
    case number do
      1 -> "it"
      _ -> "one"
    end
  end

  defp first_line(number) do
    "#{String.capitalize(bottles(number))} of beer on the wall, #{bottles(number)} of beer.\n"
  end

  defp second_line(number) do
    case number do
      0 -> "Go to the store and buy some more, 99 bottles of beer on the wall.\n"
      _ -> "Take #{one(number)} down and pass it around, #{bottles(number - 1)} of beer on the wall.\n"
    end
  end

  @doc """
  Get the entire beer song for a given range of numbers of bottles.
  """
  @spec lyrics(Range.t()) :: String.t()
  def lyrics(range) do
    range
    |> Enum.map(&verse/1)
    |> Enum.join("\n")
  end

  def lyrics() do
    lyrics(99..0)
  end
end
