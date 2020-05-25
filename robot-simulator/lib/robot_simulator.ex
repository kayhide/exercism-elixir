defmodule RobotSimulator do
  @doc """
  Create a Robot Simulator given an initial direction and position.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec create(direction :: atom, position :: {integer, integer}) :: any
  def create(direction \\ :north, position \\ {0, 0}) do
    cond do
      not is_valid_direction?(direction) -> {:error, "invalid direction"}
      not is_valid_position?(position) -> {:error, "invalid position"}
      true -> {:robot, direction, position}
    end
  end

  defp is_valid_direction?(direction) do
    direction in [:north, :east, :south, :west]
  end

  defp is_valid_position?(position) do
    case position do
      {x, y} -> is_integer(x) && is_integer(y)
      _ -> false
    end
  end

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

  defp move(char, robot) do
    case robot do
      {:robot, direction, position} ->
        case char do
          "A" ->
            case {direction, position} do
              {:north, {x, y}} -> {:robot, direction, {x, y + 1}}
              {:east, {x, y}} -> {:robot, direction, {x + 1, y}}
              {:south, {x, y}} -> {:robot, direction, {x, y - 1}}
              {:west, {x, y}} -> {:robot, direction, {x - 1, y}}
            end

          "L" ->
            case direction do
              :north -> {:robot, :west, position}
              :west -> {:robot, :south, position}
              :south -> {:robot, :east, position}
              :east -> {:robot, :north, position}
            end

          "R" ->
            case direction do
              :north -> {:robot, :east, position}
              :west -> {:robot, :north, position}
              :south -> {:robot, :west, position}
              :east -> {:robot, :south, position}
            end

          _ ->
            {:error, "invalid instruction"}
        end

      _ ->
        robot
    end
  end

  @doc """
  Return the robot's direction.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec direction(robot :: any) :: atom
  def direction({:robot, direction, _}) do
    direction
  end

  @doc """
  Return the robot's position.
  """
  @spec position(robot :: any) :: {integer, integer}
  def position({:robot, _, position}) do
    position
  end
end
