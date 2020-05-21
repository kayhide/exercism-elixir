defmodule SecretHandshake do
  @doc """
  Determine the actions of a secret handshake based on the binary
  representation of the given `code`.

  If the following bits are set, include the corresponding action in your list
  of commands, in order from lowest to highest.

  1 = wink
  10 = double blink
  100 = close your eyes
  1000 = jump

  10000 = Reverse the order of the operations in the secret handshake
  """
  @spec commands(code :: integer) :: list(String.t())
  def commands(code) do
    use Bitwise

    f = if 0 < (code &&& 0b10000), do: &Enum.reverse/1, else: &Function.identity/1

    Stream.unfold(code, fn
      0 -> nil
      x -> {0 < (x &&& 1), x >>> 1}
    end)
    |> Stream.zip(["wink", "double blink", "close your eyes", "jump"])
    |> Stream.filter(&elem(&1, 0))
    |> Stream.map(&elem(&1, 1))
    |> Enum.to_list
    |> f.()

  end
end
