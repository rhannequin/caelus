# frozen_string_literal: true

class SunController < ApplicationController
  EXTREMUM_LOOKAHEAD = 366.days
  UPCOMING_SEASONS_COUNT = 4
  GOLDEN_HOUR_ZENITH_ANGLE = Astronoby::Angle.from_degrees(84)
  BLUE_HOUR_ZENITH_ANGLES = [
    Astronoby::Angle.from_degrees(94),
    Astronoby::Angle.from_degrees(96)
  ].freeze

  def show
    @time = Time.current.localtime(@observer.utc_offset)
    @sun = Sun.new(observer: @observer, time: @time)
    @yesterday_sun = Sun.new(observer: @observer, time: @time - 1.day)
    @yearly_elevation = Rails.cache.fetch(
      "sun_elevation/#{observer_cache_key}",
      expires_at: observer_end_of_year
    ) do
      YearlyElevation.new(
        year: @time.year,
        body: Sun,
        observer: @observer,
        samples: Date.gregorian_leap?(@time.year) ? 366 : 365
      )
    end
    if @sun.rts.rising_time
      @rising_azimuth = Sun
        .new(observer: @observer, time: @sun.rts.rising_time)
        .topocentric
        .horizontal
        .azimuth
    end
    if @sun.rts.transit_time
      @transit_altitude = Sun
        .new(observer: @observer, time: @sun.rts.transit_time)
        .topocentric
        .horizontal
        .altitude
    end
    if @sun.rts.setting_time
      @setting_azimuth = Sun
        .new(observer: @observer, time: @sun.rts.setting_time)
        .topocentric
        .horizontal
        .azimuth
    end
    @twilight_event = twilight_calculator.event_on(
      @time.to_date,
      utc_offset: @observer.utc_offset
    )
    @next_perihelion = extremum_calculator
      .periapsis_events_between(@time, @time + EXTREMUM_LOOKAHEAD)
      .first
    @next_aphelion = extremum_calculator
      .apoapsis_events_between(@time, @time + EXTREMUM_LOOKAHEAD)
      .first
    @upcoming_seasons = upcoming_seasons
    @morning_golden_hour = morning_golden_hour
    @evening_golden_hour = evening_golden_hour
    @morning_blue_hour = morning_blue_hour
    @evening_blue_hour = evening_blue_hour
    @zodiac_sign = ZodiacSign.for_date(@time.to_date)
    @sub_solar_observer = SubSolarObserver.from_sun(@sun)
    @shadow_length_factor = 1 / @sun.topocentric.horizontal.altitude.tan
  end

  private

  def extremum_calculator
    Astronoby::ExtremumCalculator.new(
      body: Earth.planet_class,
      primary_body: Sun.planet_class,
      ephem: SPK.inpop19a
    )
  end

  def upcoming_seasons
    two_years_seasons = []
    [@time.to_date.year, @time.to_date.year + 1].each do |year|
      %i[
        march_equinox
        june_solstice
        september_equinox
        december_solstice
      ].each do |season|
        two_years_seasons << {
          name: season,
          time: Astronoby::EquinoxSolstice
            .public_send(season, year, SPK.inpop19a)
        }
      end
    end
    two_years_seasons
      .select { it[:time] >= @time }
      .first(UPCOMING_SEASONS_COUNT)
  end

  def twilight_calculator
    @twilight_calculator ||= Astronoby::TwilightCalculator.new(
      observer: @observer,
      ephem: SPK.inpop19a
    )
  end

  def morning_golden_hour
    [
      @sun.rts.rising_time,
      twilight_calculator.time_for_zenith_angle(
        date: @time.to_date,
        period_of_the_day: Astronoby::TwilightCalculator::MORNING,
        zenith_angle: GOLDEN_HOUR_ZENITH_ANGLE,
        utc_offset: @observer.utc_offset
      )
    ]
  end

  def evening_golden_hour
    [
      twilight_calculator.time_for_zenith_angle(
        date: @time.to_date,
        period_of_the_day: Astronoby::TwilightCalculator::EVENING,
        zenith_angle: GOLDEN_HOUR_ZENITH_ANGLE,
        utc_offset: @observer.utc_offset
      ),
      @sun.rts.setting_time
    ]
  end

  def morning_blue_hour
    [
      twilight_calculator.time_for_zenith_angle(
        date: @time.to_date,
        period_of_the_day: Astronoby::TwilightCalculator::MORNING,
        zenith_angle: BLUE_HOUR_ZENITH_ANGLES.second,
        utc_offset: @observer.utc_offset
      ),
      twilight_calculator.time_for_zenith_angle(
        date: @time.to_date,
        period_of_the_day: Astronoby::TwilightCalculator::MORNING,
        zenith_angle: BLUE_HOUR_ZENITH_ANGLES.first,
        utc_offset: @observer.utc_offset
      )
    ]
  end

  def evening_blue_hour
    [
      twilight_calculator.time_for_zenith_angle(
        date: @time.to_date,
        period_of_the_day: Astronoby::TwilightCalculator::EVENING,
        zenith_angle: BLUE_HOUR_ZENITH_ANGLES.first,
        utc_offset: @observer.utc_offset
      ),
      twilight_calculator.time_for_zenith_angle(
        date: @time.to_date,
        period_of_the_day: Astronoby::TwilightCalculator::EVENING,
        zenith_angle: BLUE_HOUR_ZENITH_ANGLES.second,
        utc_offset: @observer.utc_offset
      )
    ]
  end
end
