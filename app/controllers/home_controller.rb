# frozen_string_literal: true

class HomeController < ApplicationController
  MAXIMUM_DEEP_SKY_OBJECTS = 8

  def index
    @planets = [
      Mercury.new(observer: @observer, time: @time),
      Venus.new(observer: @observer, time: @time),
      Mars.new(observer: @observer, time: @time),
      Jupiter.new(observer: @observer, time: @time),
      Saturn.new(observer: @observer, time: @time),
      Uranus.new(observer: @observer, time: @time),
      Neptune.new(observer: @observer, time: @time)
    ]

    @sun = Sun.new(observer: @observer, time: @time)

    @moon = Moon.new(observer: @observer, time: @time)

    @twilight_events = Rails.cache.fetch(
      "twilight_events/#{observer_daily_cache_key}",
      expires_at: observer_end_of_day
    ) do
      Astronoby::TwilightCalculator.new(
        observer: @observer,
        ephem: spk
      ).event_on(
        @time.to_date,
        utc_offset: @observer.time_zone.formatted_offset
      )
    end

    @next_twilight_events = Rails.cache.fetch(
      "next_twilight_events/#{observer_daily_cache_key}",
      expires_at: observer_end_of_day
    ) do
      Astronoby::TwilightCalculator.new(
        observer: @observer,
        ephem: spk
      ).event_on(@time.to_date + 1)
    end

    @observing_night = ObservingNight.new(
      observer: @observer,
      date: @time.to_date
    )

    @deep_sky_object_positions = DeepSkyObjectsCatalog
      .find_all_by_designation(best_designations)
      .map do |deep_sky_object|
        deep_sky_object.at(
          @time,
          observer: @observer,
          use_ephem: true,
          night: @observing_night
        )
      end

    track_page_view("home")
  end

  private

  def best_designations
    Rails.cache.fetch(
      "deep_sky_ranking/#{observer_daily_cache_key}",
      expires_at: observer_end_of_day
    ) do
      DeepSkyRanking
        .new(night: @observing_night)
        .best(MAXIMUM_DEEP_SKY_OBJECTS)
        .map { |placement| placement.deep_sky_object.designation }
    end
  end
end
