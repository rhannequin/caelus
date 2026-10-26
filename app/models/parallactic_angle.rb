# frozen_string_literal: true

module ParallacticAngle
  module_function

  def at(equatorial:, observer:, time:)
    declination = equatorial.declination
    hour_angle = equatorial.compute_hour_angle(
      time: time,
      longitude: observer.longitude
    )

    Astronoby::Angle.from_radians(
      Math.atan2(
        hour_angle.sin,
        observer.latitude.tan * declination.cos -
          declination.sin * hour_angle.cos
      )
    )
  end
end
