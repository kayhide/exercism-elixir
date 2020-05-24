defmodule SpaceAge do
  @type planet ::
          :mercury
          | :venus
          | :earth
          | :mars
          | :jupiter
          | :saturn
          | :uranus
          | :neptune

  @doc """
  Return the number of years a person that has lived for 'seconds' seconds is
  aged on 'planet'.
  """
  @spec age_on(planet, pos_integer) :: float
  def age_on(planet, seconds) do
    seconds / orbital_period_of(planet)
  end

  defp orbital_period_of(planet) do
    base = 31557600.0           # 1 earth year in seconds
    case planet do
      :mercury -> 0.2408467 * base
      :venus -> 0.61519726 * base
      :earth -> 1.0 * base
      :mars -> 1.8808158 * base
      :jupiter -> 11.862615 * base
      :saturn -> 29.447498 * base
      :uranus -> 84.016846 * base
      :neptune -> 164.79132 * base
    end
  end
end
