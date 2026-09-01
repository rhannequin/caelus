# frozen_string_literal: true

module AngularSeparation
  module_function

  def between(first, second)
    first_declination = first.declination.radians
    second_declination = second.declination.radians
    right_ascension_difference =
      first.right_ascension.radians - second.right_ascension.radians

    cosine = Math.sin(first_declination) * Math.sin(second_declination) +
      Math.cos(first_declination) *
        Math.cos(second_declination) *
        Math.cos(right_ascension_difference)

    Astronoby::Angle.from_radians(Math.acos(cosine.clamp(-1.0, 1.0)))
  end
end
