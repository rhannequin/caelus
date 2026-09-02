# frozen_string_literal: true

module CelestialEvents
  class PlanetaryConjunctionsGenerator
    include CloseApproaches

    PLANETS = %w[Mercury Venus Mars Jupiter Saturn].freeze
    MAXIMUM_SEPARATION = Astronoby::Angle.from_degrees(5)
    MINIMUM_SOLAR_ELONGATION = Astronoby::Angle.from_degrees(10)

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def generate
      astronoby_events.each do |approach|
        CelestialEvent.create!(
          kind: CelestialEvent::PLANETARY_CONJUNCTION,
          primary_body: approach.primary.name.demodulize,
          secondary_body: approach.secondary.name.demodulize,
          peak_tt: Astronoby::Instant.from_time(approach.time).tt
        )
      end
    end

    private

    def astronoby_events
      pairs
        .flat_map { |primary, secondary| close_approaches(primary, secondary) }
        .select { |approach| worthwhile?(approach) }
    end

    def worthwhile?(approach)
      approach.separation <= MAXIMUM_SEPARATION &&
        approach.solar_elongation >= MINIMUM_SOLAR_ELONGATION
    end

    def pairs
      PLANETS.map { |name| "Astronoby::#{name}".constantize }.combination(2)
    end
  end
end
