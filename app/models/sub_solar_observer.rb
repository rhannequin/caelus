# frozen_string_literal: true

class SubSolarObserver
  def self.from_sun(sun)
    new(
      sun.apparent.equatorial.right_ascension,
      sun.apparent.equatorial.declination,
      sun.time
    ).observer
  end

  def initialize(sun_right_ascension, sun_declination, time)
    @sun_right_ascension = sun_right_ascension
    @sun_declination = sun_declination
    @time = time
  end

  def observer
    sidereal_time = Astronoby::GreenwichSiderealTime
      .from_utc(@time.utc)
      .time
    longitude = @sun_right_ascension -
      Astronoby::Angle.from_hours(sidereal_time)
    sub_solar_longitude = Astronoby::Angle.from_degrees(
      (longitude.degrees + 180) % 360 - 180
    )

    Astronoby::Observer.new(
      latitude: @sun_declination,
      longitude: sub_solar_longitude
    )
  end
end
