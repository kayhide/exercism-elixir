defmodule RotationalCipher do
  @doc """
  Given a plaintext and amount to shift by, return a rotated string.

  Example:
  iex> RotationalCipher.rotate("Attack at dawn", 13)
  "Nggnpx ng qnja"
  """
  @spec rotate(text :: String.t(), shift :: integer) :: String.t()
  def rotate(text, shift) do
    text
    |> String.replace(~r/[a-z]/u, fn <<c>> -> <<Integer.mod(c - ?a + shift, 26) + ?a>> end)
    |> String.replace(~r/[A-Z]/u, fn <<c>> -> <<Integer.mod(c - ?A + shift, 26) + ?A>> end)
  end
end
