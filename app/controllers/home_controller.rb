# frozen_string_literal: true

class HomeController < ApplicationController
  MAXIMUM_DEEP_SKY_OBJECTS = 10

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

    @messier_object_positions = MessierCatalog
      .all
      .sort_by(&:magnitude)
      .first(MAXIMUM_DEEP_SKY_OBJECTS)
      .map { |obj| obj.at(@time, observer: @observer, use_ephem: true) }

    track_page_view("home")
  end
end
