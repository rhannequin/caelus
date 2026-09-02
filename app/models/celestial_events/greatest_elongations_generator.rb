# frozen_string_literal: true

module CelestialEvents
  class GreatestElongationsGenerator
    PLANETS = %w[Mercury Venus].freeze

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def generate
      astronoby_events.each do |greatest_elongation|
        CelestialEvent.create!(
          kind: CelestialEvent::GREATEST_ELONGATION,
          primary_body: greatest_elongation.body.name.demodulize,
          peak_tt: greatest_elongation.instant.tt
        )
      end
    end

    private

    def astronoby_events
      PLANETS.each_with_object([]) do |planet, events|
        events.concat(generate_greatest_elongations_for_planet(planet))
      end
    end

    def generate_greatest_elongations_for_planet(planet)
      "Astronoby::#{planet}".constantize.greatest_elongation_events(
        ephem: SPK.inpop19a,
        start_time: @start_date,
        end_time: @end_date
      )
    end
  end
end
