defmodule Markdown do
  @doc """
    Parses a given string with Markdown syntax and returns the associated HTML for that string.

    ## Examples

    iex> Markdown.parse("This is a paragraph")
    "<p>This is a paragraph</p>"

    iex> Markdown.parse("#Header!\n* __Bold Item__\n* _Italic Item_")
    "<h1>Header!</h1><ul><li><em>Bold Item</em></li><li><i>Italic Item</i></li></ul>"
  """
  @spec parse(String.t()) :: String.t()
  def parse(m) do
    run_parser(document(), m)
  end

  # parsers

  defp document() do
    some(asum([header(), list(), paragraph()]))
    |> fmap(&Enum.join/1)
  end

  defp header() do
    symbol(some(chunk("#")))
    |> bind(fn n ->
      line()
      |> fmap(tag("h#{length(n)}"))
    end)
  end

  defp list() do
    some(list_item())
    |> fmap(&tag("ul").(Enum.join(&1)))
  end

  defp list_item() do
    symbol(chunk("*"))
    |> bind(fn _ ->
      line()
      |> fmap(tag("li"))
    end)
  end

  defp paragraph() do
    line()
    |> fmap(tag("p"))
  end

  defp strong() do
    between(chunk("__"), text())
    |> fmap(tag("strong"))
  end

  defp italic() do
    between(chunk("_"), text())
    |> fmap(tag("em"))
  end

  defp line() do
    some(asum([strong(), italic(), text()]))
    |> bind(fn x ->
      eol()
      |> fmap(fn _ -> x end)
    end)
  end

  # helper parsers

  defp text() do
    some(satisfy(&String.match?(&1, ~r/[0-9a-zA-Z !]/)))
    |> fmap(&Enum.join/1)
  end

  defp symbol(p) do
    p
    |> bind(fn x ->
      some(chunk(" "))
      |> fmap(fn _ -> x end)
    end)
  end

  defp eol() do
    alt(chunk("\n"), eof())
  end

  defp between(p1, p2) do
    p1
    |> bind(fn _ ->
      p2
      |> bind(fn x ->
        p1
        |> fmap(fn _ -> x end)
      end)
    end)
  end

  # helper functions

  defp tag(key) do
    fn text ->
      "<#{key}>#{text}</#{key}>"
    end
  end

  # parser monad
  # m a :: string -> {a, string} | :fail

  # run_parser :: m a -> string | :fail
  defp run_parser(p, str) do
    case p.(str) do
      :fail -> :fail
      {res, _} -> res
    end
  end

  # pure :: a -> m a
  defp pure(x) do
    fn str -> {x, str} end
  end

  # fmap :: m a -> (a -> b) -> m b
  defp fmap(x, f) do
    fn str ->
      case x.(str) do
        :fail -> :fail
        {y, str_} -> {f.(y), str_}
      end
    end
  end

  # bind :: m a -> (a -> m b) -> m b
  defp bind(x, act) do
    fn str ->
      case x.(str) do
        :fail -> :fail
        {y, str_} -> act.(y).(str_)
      end
    end
  end

  defp fail() do
    fn _ -> :fail end
  end

  # alternative

  # alt :: m a -> m a -> m a
  defp alt(p1, p2) do
    fn str ->
      case p1.(str) do
        :fail -> p2.(str)
        res -> res
      end
    end
  end

  # some :: m a -> m [a]
  defp some(p) do
    p
    |> bind(fn x ->
      alt(fmap(some(p), &[x | &1]), pure([x]))
    end)
  end

  # asum :: [m a] -> m a
  defp asum(ps), do: Enum.reduce(ps, fail(), &alt(&1, &2))

  # primitives

  # satisfy :: (a -> bool) -> m a
  defp satisfy(pred) do
    fn str ->
      {x, xs} = String.split_at(str, 1)
      if pred.(x), do: {x, xs}, else: :fail
    end
  end

  # chunk :: a -> m a
  defp chunk(x) do
    fn str ->
      case String.split_at(str, String.length(x)) do
        {^x, xs} -> {x, xs}
        _ -> :fail
      end
    end
  end

  defp eof() do
    fn
      "" -> {nil, ""}
      _ -> :fail
    end
  end
end
