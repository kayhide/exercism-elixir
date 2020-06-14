defmodule Functor do
  # f a -> (a -> b) -> f b
  @callback fmap(term, (term -> term)) :: term
end

defmodule Applicative do
  import Functor
  # a -> f a
  @callback pure(term) :: term
  # f a -> f (a -> b) -> f b
  @callback app(term, term) :: term
end

defmodule Alternative do
  import Functor
  # f a
  @callback empty() :: term
  # f a -> f a -> f a
  @callback alt(term, term) :: term

  @doc """
  Implemented in terms of Monad
  """
  # m a -> m [a]
  @spec some(module, term) :: term
  def some(impl, p) do
    p
    |> impl.bind(fn x ->
      impl.alt(impl.fmap(some(impl, p), &[x | &1]), impl.pure([x]))
    end)
  end

  # [m a] -> m a
  @spec asum(module, [term]) :: term
  def asum(impl, ps), do: Enum.reduce(ps, impl.empty(), &impl.alt(&1, &2))
end

defmodule Monad do
  import Applicative
  @callback bind(term, term) :: term
end

defmodule Parser do
  @behaviour Functor
  @behaviour Applicative
  @behaviour Alternative
  @behaviour Monad

  @type t(a) :: %__MODULE__{run: (String.t() -> {a, String.t()} | :fail)}

  defstruct run: &Parser.fail/1

  @spec fail(String.t()) :: :fail
  def fail(_), do: :fail

  @spec run_parser(t(String.t()), String.t()) :: String.t() | :fail
  def run_parser(%Parser{run: run}, str) do
    case run.(str) do
      :fail -> :fail
      {res, _} -> res
    end
  end

  @impl Functor
  @spec fmap(t(a), (a -> b)) :: t(b) when a: term, b: term
  def fmap(%Parser{run: run}, f) do
    %Parser{
      run: fn str ->
        case run.(str) do
          :fail -> :fail
          {y, str_} -> {f.(y), str_}
        end
      end
    }
  end

  @impl Applicative
  def pure(x) do
    %Parser{
      run: fn str -> {x, str} end
    }
  end

  @impl Applicative
  def app(%Parser{run: x}, %Parser{run: f}) do
    %Parser{
      run: fn str -> {f.(x), str} end
    }
  end

  @impl Alternative
  def empty(), do: %Parser{}

  @impl Alternative
  def alt(%Parser{run: p1}, %Parser{run: p2}) do
    %Parser{
      run: fn str ->
        case p1.(str) do
          :fail -> p2.(str)
          res -> res
        end
      end
    }
  end

  @impl Monad
  def bind(%Parser{run: run}, act) do
    %Parser{
      run: fn str ->
        case run.(str) do
          :fail ->
            :fail

          {y, str_} ->
            case act.(y) do
              %Parser{run: run2} -> run2.(str_)
            end
        end
      end
    }
  end
end

defmodule PrimitiveParsers do
  @moduledoc """
  Primitive and helper parsers
  """

  import Alternative
  import Monad
  import Parser

  @spec satisfy((String.t() -> boolean)) :: Parser.t(String.t())
  def satisfy(pred) do
    %Parser{
      run: fn str ->
        {x, xs} = String.split_at(str, 1)
        if pred.(x), do: {x, xs}, else: :fail
      end
    }
  end

  @spec chunk(String.t()) :: Parser.t(String.t())
  def chunk(x) do
    %Parser{
      run: fn str ->
        case String.split_at(str, String.length(x)) do
          {^x, xs} -> {x, xs}
          _ -> :fail
        end
      end
    }
  end

  @spec eof() :: Parser.t(nil)
  def eof() do
    %Parser{
      run: fn
        "" -> {nil, ""}
        _ -> :fail
      end
    }
  end

  @spec symbol(Parser.t(String.t())) :: Parser.t(String.t())
  def symbol(p) do
    p
    |> bind(fn x ->
      some(Parser, chunk(" "))
      |> fmap(fn _ -> x end)
    end)
  end

  @spec eol() :: Parser.t(nil)
  def eol() do
    alt(chunk("\n"), eof())
  end

  @spec between(Parser.t(String.t()), Parser.t(String.t())) :: Parser.t(String.t())
  def between(p1, p2) do
    p1
    |> bind(fn _ ->
      p2
      |> bind(fn x ->
        p1
        |> fmap(fn _ -> x end)
      end)
    end)
  end
end

defmodule Markdown do
  import Alternative
  import Parser
  import PrimitiveParsers

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

  defp document() do
    some(Parser, asum(Parser, [header(), list(), paragraph()]))
    |> fmap(&Enum.join/1)
  end

  defp header() do
    symbol(some(Parser, chunk("#")))
    |> bind(fn n ->
      line()
      |> fmap(tag("h#{length(n)}"))
    end)
  end

  defp list() do
    some(Parser, list_item())
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
    some(Parser, asum(Parser, [strong(), italic(), text()]))
    |> bind(fn x ->
      eol()
      |> fmap(fn _ -> x end)
    end)
  end

  defp text() do
    some(Parser, satisfy(&String.match?(&1, ~r/[0-9a-zA-Z !]/)))
    |> fmap(&Enum.join/1)
  end

  @spec tag(String.t()) :: (String.t() -> String.t())
  defp tag(key) do
    fn text ->
      "<#{key}>#{text}</#{key}>"
    end
  end
end
