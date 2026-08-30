# frozen_string_literal: true

module CelestialEvents
  class OppositionsGenerator
    PLANETS = %w[Mars Jupiter Saturn Uranus Neptune].freeze

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def generate
      astronoby_events.each do |opposition|
        CelestialEvent.create!(
          kind: CelestialEvent::OPPOSITION,
          peak_tt: opposition.instant.tt
        )
      end
    end

    private

    def astronoby_events
      PLANETS.each_with_object([]) do |planet, events|
        events.concat(generate_oppositions_for_planet(planet))
      end
    end

    def generate_oppositions_for_planet(planet)
      "Astronoby::#{planet}".constantize.opposition_events(
        ephem: SPK.inpop19a,
        start_time: @start_date,
        end_time: @end_date
      )
    end
  end
end
