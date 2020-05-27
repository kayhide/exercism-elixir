defmodule RobotSimulator do
  defguard is_direction(direction)
           when direction in [:north, :east, :south, :west]

  @doc """
  Create a Robot Simulator given an initial direction and position.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec create(direction :: atom, position :: {integer, integer}) :: any
  def create(direction \\ :north, position \\ {0, 0})

  def create(direction, {x, y})
      when is_direction(direction) and is_integer(x) and is_integer(y),
      do: {:robot, from_direction(direction), {x, y}}

  def create(direction, _) when not is_direction(direction),
    do: {:error, "invalid direction"}

  def create(_, _),
    do: {:error, "invalid position"}

  @doc """
  Encode a direction symbol to a vector.
  """
  defp from_direction(:north), do: {0, 1}
  defp from_direction(:east), do: {1, 0}
  defp from_direction(:south), do: {0, -1}
  defp from_direction(:west), do: {-1, 0}

  @doc """
  Decode a vector to a direction.
  """
  defp to_direction({0, 1}), do: :north
  defp to_direction({1, 0}), do: :east
  defp to_direction({0, -1}), do: :south
  defp to_direction({-1, 0}), do: :west

  @doc """
  Simulate the robot's movement given a string of instructions.

  Valid instructions are: "R" (turn right), "L", (turn left), and "A" (advance)
  """
  @spec simulate(robot :: any, instructions :: String.t()) :: any
  def simulate(robot, instructions) do
    instructions
    |> String.graphemes()
    |> Enum.reduce(robot, &move/2)
  end

  defp move("A", {:robot, {dx, dy}, {x, y}}), do: {:robot, {dx, dy}, {x + dx, y + dy}}
  defp move("L", {:robot, {dx, dy}, position}), do: {:robot, {-dy, dx}, position}
  defp move("R", {:robot, {dx, dy}, position}), do: {:robot, {dy, -dx}, position}
  defp move(_, {:robot, _, _}), do: {:error, "invalid instruction"}
  defp move(_, x), do: x

  @doc """
  Return the robot's direction.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec direction(robot :: any) :: atom
  def direction({:robot, vector, _}) do
    to_direction(vector)
  end

  @doc """
  Return the robot's position.
  """
  @spec position(robot :: any) :: {integer, integer}
  def position({:robot, _, position}) do
    position
  end
end
