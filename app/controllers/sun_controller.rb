# frozen_string_literal: true

class SunController < ApplicationController
  EXTREMUM_LOOKAHEAD = 366.days

  def show
    @sun = Sun.new(observer: @observer, time: @time)
    @yesterday_sun = Sun.new(observer: @observer, time: @time - 1.day)
    @yearly_elevation = YearlyElevation.new(
      year: @time.year,
      body: Sun,
      observer: @observer,
      samples: Date.gregorian_leap?(@time.year) ? 366 : 365
    )
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
    @upcoming_seasons = UpcomingSeasons.new(time: @time)
    @golden_blue_hour_calculator = GoldenBlueHourCalculator.new(
      observer: @observer,
      date: @time.to_date
    )
    @zodiac_sign = ZodiacSign.for_date(@time.to_date)
    @sub_solar_observer = SubSolarObserver.from_sun(@sun)

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
