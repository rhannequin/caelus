# frozen_string_literal: true

module CelestialEvents
  class Generator
    EVENT_TYPES = [
      EQUINOXES_SOLSTICES = :equinoxes_solstices,
      GREATEST_ELONGATIONS = :greatest_elongations,
      LUNAR_ECLIPSES = :lunar_eclipses,
      MOON_PHASES = :moon_phases,
      MOON_PLANET_CONJUNCTIONS = :moon_planet_conjunctions,
      OPPOSITIONS = :oppositions,
      PLANETARY_CONJUNCTIONS = :planetary_conjunctions
    ].freeze

    GENERATORS = {
      EQUINOXES_SOLSTICES => EquinoxesSolsticesGenerator,
      GREATEST_ELONGATIONS => GreatestElongationsGenerator,
      LUNAR_ECLIPSES => LunarEclipsesGenerator,
      MOON_PHASES => MoonPhasesGenerator,
      MOON_PLANET_CONJUNCTIONS => MoonPlanetConjunctionsGenerator,
      OPPOSITIONS => OppositionsGenerator,
      PLANETARY_CONJUNCTIONS => PlanetaryConjunctionsGenerator
    }.freeze

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def generate_all
      EVENT_TYPES.each do |event_type|
        generate(event_type)
      end
    end

    def generate(event_type)
      ensure_event_type!(event_type)

      generator_class = GENERATORS[event_type]
      generator = generator_class.new(@start_date, @end_date)
      generator.generate
    end

    private

    def ensure_event_type!(event_type)
      unless EVENT_TYPES.include?(event_type)
        raise ArgumentError, "Unsupported event type: #{event_type}"
      end
    end
  end
end
