# frozen_string_literal: true

class HomeController < ApplicationController
  MAXIMUM_DEEP_SKY_OBJECTS = 10

  def index
    @planets = Rails.cache.fetch(
      "planets/#{observer_cache_key}/#{Date.current}",
      expires_at: observer_end_of_day
    ) do
      [
        Mercury.new(observer: @observer),
        Venus.new(observer: @observer),
        Mars.new(observer: @observer),
        Jupiter.new(observer: @observer),
        Saturn.new(observer: @observer),
        Uranus.new(observer: @observer),
        Neptune.new(observer: @observer)
      ]
    end

    @sun = Rails.cache.fetch(
      "sun/#{observer_cache_key}",
      expires_in: 1.hour
    ) do
      Sun.new(observer: @observer)
    end

    @moon = Rails.cache.fetch(
      "moon/#{observer_cache_key}",
      expires_in: 1.hour
    ) do
      Moon.new(observer: @observer)
    end

    @twilight_events = Rails.cache.fetch(
      "twilight_events/#{observer_cache_key}/#{Date.current}",
      expires_at: observer_end_of_day
    ) do
      Astronoby::TwilightCalculator.new(
        observer: @observer,
        ephem: SPK.inpop19a
      ).event_on(Date.today, utc_offset: @observer.utc_offset)
    end

    @next_twilight_events = Rails.cache.fetch(
      "next_twilight_events/#{observer_cache_key}/#{Date.current}",
      expires_at: observer_end_of_day
    ) do
      Astronoby::TwilightCalculator.new(
        observer: @observer,
        ephem: SPK.inpop19a
      ).event_on(Date.tomorrow)
    end

    @messier_object_positions = Rails.cache.fetch(
      "messier_object_positions/#{observer_cache_key}/#{Date.current}",
      expires_at: observer_end_of_day
    ) do
      MessierCatalog
        .all
        .map { |obj| obj.at(Time.now, observer: @observer, use_ephem: true) }
        .max(MAXIMUM_DEEP_SKY_OBJECTS) do |a, b|
          b.messier_object.magnitude <=> a.messier_object.magnitude
        end
    end
  end
end
