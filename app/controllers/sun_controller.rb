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
    @sun = Sun.new(observer: @observer, time: @time)
    @yesterday_sun = Sun.new(observer: @observer, time: @time - 1.day)
    @yearly_elevation = Rails.cache.fetch(
      "sun_elevation/#{observer_yearly_cache_key}",
      expires_at: observer_end_of_year
    ) do
      YearlyElevation.new(
        year: @time.year,
        body: Sun,
        observer: @observer,
        samples: Date.gregorian_leap?(@time.year) ? 366 : 365
      )
    end
    @twilight_event = twilight_calculator.event_on(
      @time.to_date,
      utc_offset: @observer.time_zone.formatted_offset
    )
    @next_perihelion = extremum_calculator
      .periapsis_events_between(@time, @time + EXTREMUM_LOOKAHEAD)
      .first
    @next_aphelion = extremum_calculator
      .apoapsis_events_between(@time, @time + EXTREMUM_LOOKAHEAD)
      .first
    @upcoming_seasons = upcoming_seasons
    @golden_blue_hour_calculator = GoldenBlueHourCalculator.new(
      observer: @observer,
      date: @time.to_date
    )
    @zodiac_sign = ZodiacSign.for_date(@time.to_date)
    @sub_solar_observer = SubSolarObserver.from_sun(@sun)
    @shadow_length_factor = 1 / @sun.topocentric.horizontal.altitude.tan

    track_page_view("sun")
  end

  private

  def extremum_calculator
    @extremum_calculator ||= Astronoby::ExtremumCalculator.new(
      body: Earth.planet_class,
      primary_body: Sun.planet_class,
      ephem: spk
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
            .public_send(season, year, spk)
        }
      end
    end
    two_years_seasons
      .select { |season| season[:time] >= @time }
      .first(UPCOMING_SEASONS_COUNT)
  end

  def twilight_calculator
    @twilight_calculator ||= Astronoby::TwilightCalculator.new(
      observer: @observer,
      ephem: spk
    )
  end

  def spk
    @spk ||= SPK.for_time(@time)
  end
end
