# frozen_string_literal: true

class Sun
  ABSOLUTE_MAGNITUDE = 4.83
  AU_IN_PARSEC = 1 / 206265.0

  include Planetable

  def self.planet_class
    Astronoby::Sun
  end

  def self.key
    :sun
  end

  def initialize(observer:, time: Time.now)
    @observer = observer
    @time = time
  end

  delegate :equation_of_time, to: :planet

  # Source: https://en.wikipedia.org/wiki/Apparent_magnitude
  def magnitude
    @magnitude ||=
      ABSOLUTE_MAGNITUDE +
      5 * (Math.log10(distance_from_earth.au * AU_IN_PARSEC) - 1)
  end
end
