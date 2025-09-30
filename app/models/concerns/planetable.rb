# frozen_string_literal: true

module Planetable
  extend ActiveSupport::Concern

  class_methods do
    def planet_class
      raise NotImplementedError,
        "You must implement the .planet_class class method in #{name}"
    end

    def key
      raise NotImplementedError,
        "You must implement the .key class method in #{name}"
    end

    def planet_name
      I18n.t("models.planets.#{key}.name")
    end
  end

  included do
    attr_reader :time

    delegate :angular_diameter,
      :apparent,
      :astrometric,
      :approaching_primary?,
      to: :planet

    def distance_from_earth
      @distance_from_earth ||=
        (planet.geometric.position - current_earth_geometric.position)
          .magnitude
    end

    def magnitude
      @magnitude ||= planet.apparent_magnitude
    end

    def illuminated_percentage
      @illuminated_percentage ||= planet.illuminated_fraction * 100
    end

    def rts
      @rts ||= Astronoby::RiseTransitSetCalculator.new(
        body: self.class.planet_class,
        observer: @observer,
        ephem: SPK.inpop19a
      ).event_on(@time.to_date)
    end

    def visibility
      @visibility ||= Visibility.new(
        body: self.class,
        observer: @observer,
        date: @time.to_date
      )
    end

    def topocentric
      @topocentric ||= planet.observed_by(@observer)
    end

    def constellation
      @constellation ||= Constellation.from_astronoby(planet.constellation)
    end

    private

    def planet
      @planet ||= self.class.planet_class.new(
        ephem: SPK.inpop19a,
        instant: Astronoby::Instant.from_time(@time)
      )
    end

    def current_earth_geometric
      @current_earth_geometric ||= Astronoby::Earth.geometric(
        ephem: SPK.inpop19a,
        instant: Astronoby::Instant.from_time(@time)
      )
    end
  end
end
