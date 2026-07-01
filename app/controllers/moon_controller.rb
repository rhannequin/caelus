# frozen_string_literal: true

class MoonController < ApplicationController
  MAJOR_MOON_PHASES = 4

  # More than Moon orbit period
  EXTREMUM_LOOKAHEAD = 30.days

  # 3 previous days, today, and 3 next days
  WEEK_RANGE = (-3..3).to_a.freeze

  def show
    @moon = Moon.new(observer: @observer, time: @time)

    @next_apogee = Rails.cache.fetch(
      "moon_next_apogee/#{observer_daily_cache_key}",
      expires_at: observer_end_of_day
    ) do
      extremum_calculator
        .apoapsis_events_between(@time, @time + EXTREMUM_LOOKAHEAD)
        .first
    end

    @next_perigee = Rails.cache.fetch(
      "moon_next_perigee/#{observer_daily_cache_key}",
      expires_at: observer_end_of_day
    ) do
      extremum_calculator
        .periapsis_events_between(@time, @time + EXTREMUM_LOOKAHEAD)
        .first
    end

    @upcoming_phases = Rails.cache.fetch(
      "moon_upcoming_phases/#{observer_daily_cache_key}",
      expires_at: observer_end_of_day
    ) { upcoming_phases }

    @week = Rails.cache.fetch(
      "moon_week/#{observer_daily_cache_key}",
      expires_at: observer_end_of_day
    ) { week_of_moons }

    track_page_view("moon")
  end

  private

  # Returns the next four major moon phases
  def upcoming_phases
    current_month_phases = Astronoby::Events::MoonPhases.phases_for(
      year: @time.year,
      month: @time.month
    ).to_a
    next_month_phases = Astronoby::Events::MoonPhases.phases_for(
      year: @time.year,
      month: @time.next_month.month
    ).to_a
    (current_month_phases + next_month_phases)
      .select { it.time >= @time }
      .first(MAJOR_MOON_PHASES)
  end

  def week_of_moons
    WEEK_RANGE.map do |i|
      if i.zero?
        @moon
      else
        Moon.new(observer: @observer, time: @time + i.days)
      end
    end
  end

  def extremum_calculator
    @extremum_calculator ||= Astronoby::ExtremumCalculator.new(
      body: Moon.planet_class,
      primary_body: Earth.planet_class,
      ephem: spk
    )
  end
end
