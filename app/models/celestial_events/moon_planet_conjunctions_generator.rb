# frozen_string_literal: true

module CelestialEvents
  class MoonPlanetConjunctionsGenerator
    include CloseApproaches

    PLANETS = %w[Mercury Venus Mars Jupiter Saturn].freeze
    MINIMUM_SOLAR_ELONGATION = Astronoby::Angle.from_degrees(10)
    MAXIMUM_MAGNITUDE = 1.5

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def generate
      astronoby_events.each do |approach|
        CelestialEvent.create!(
          kind: CelestialEvent::MOON_PLANET_CONJUNCTION,
          primary_body: approach.secondary.name.demodulize,
          peak_tt: Astronoby::Instant.from_time(approach.time).tt
        )
      end
    end

    private

    def astronoby_events
      planets
        .flat_map { |planet| close_approaches(Astronoby::Moon, planet) }
        .select { |approach| worthwhile?(approach) }
    end

    def worthwhile?(approach)
      approach.solar_elongation >= MINIMUM_SOLAR_ELONGATION &&
        magnitude(approach.secondary, approach.time) <= MAXIMUM_MAGNITUDE
    end

    def planets
      PLANETS.map { |name| "Astronoby::#{name}".constantize }
    end
  end
end
