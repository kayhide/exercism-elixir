defmodule ListOps do
  # Please don't use any external modules (especially List or Enum) in your
  # implementation. The point of this exercise is to create these basic
  # functions yourself. You may use basic Kernel functions (like `Kernel.+/2`
  # for adding numbers), but please do not use Kernel functions for Lists like
  # `++`, `--`, `hd`, `tl`, `in`, and `length`.

  @spec count(list) :: non_neg_integer
  def count(l), do: reduce(l, 0, fn _, acc -> 1 + acc end)

  @spec reverse(list) :: list
  def reverse(l), do: reduce(l, [], &([&1 | &2]))

  @spec map(list, (any -> any)) :: list
  def map(l, f), do: for(x <- l, do: f.(x))

  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter([], f), do: []
  def filter([x | xs], f), do:
    if f.(x), do: [x | filter(xs, f)], else: filter(xs,f)

  @type acc :: any
  @spec reduce(list, acc, (any, acc -> acc)) :: acc
  def reduce([], acc, _f), do: acc
  def reduce([x | xs], acc, f), do: reduce(xs, f.(x, acc), f)

  @spec append(list, list) :: list
  def append([], b), do: b
  def append([x | xs], b), do: [x | append(xs, b)]

  @spec concat([[any]]) :: [any]
  def concat([]), do: []
  def concat([xs | xss]), do: append(xs, concat(xss))
end
