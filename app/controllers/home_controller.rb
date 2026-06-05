# frozen_string_literal: true

class HomeController < ApplicationController
  MAXIMUM_DEEP_SKY_OBJECTS = 10

  def index
    @planets = Rails.cache.fetch(
      "planets/#{observer_daily_cache_key}",
      expires_at: observer_end_of_day
    ) do
      [
        Mercury.new(observer: @observer, time: @time),
        Venus.new(observer: @observer, time: @time),
        Mars.new(observer: @observer, time: @time),
        Jupiter.new(observer: @observer, time: @time),
        Saturn.new(observer: @observer, time: @time),
        Uranus.new(observer: @observer, time: @time),
        Neptune.new(observer: @observer, time: @time)
      ]
    end

    @sun = Rails.cache.fetch(
      "sun/#{observer_daily_cache_key}",
      expires_in: 1.hour
    ) do
      Sun.new(observer: @observer, time: @time)
    end

    @moon = Rails.cache.fetch(
      "moon/#{observer_daily_cache_key}",
      expires_in: 1.hour
    ) do
      Moon.new(observer: @observer, time: @time)
    end

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

    @messier_object_positions = Rails.cache.fetch(
      "messier_object_positions/#{observer_daily_cache_key}",
      expires_at: observer_end_of_day
    ) do
      MessierCatalog
        .all
        .sort_by(&:magnitude)
        .first(MAXIMUM_DEEP_SKY_OBJECTS)
        .map { |obj| obj.at(@time, observer: @observer, use_ephem: true) }
    end

    track_page_view("home")
  end

  private

  def spk
    SPK.for_time(@time)
  end
end
