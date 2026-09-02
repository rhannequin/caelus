# frozen_string_literal: true

module CelestialEvents
  class Generator
    EVENT_TYPES = [
      EARTH_APHELIA_PERIHELIA = :earth_aphelia_perihelia,
      EQUINOXES_SOLSTICES = :equinoxes_solstices,
      GREATEST_ELONGATIONS = :greatest_elongations,
      LUNAR_ECLIPSES = :lunar_eclipses,
      MOON_APOGEES_PERIGEES = :moon_apogees_perigees,
      MOON_PHASES = :moon_phases,
      MOON_PLANET_CONJUNCTIONS = :moon_planet_conjunctions,
      OPPOSITIONS = :oppositions,
      PLANETARY_CONJUNCTIONS = :planetary_conjunctions
    ].freeze

    GENERATORS = {
      EARTH_APHELIA_PERIHELIA => EarthApheliaPeriheliaGenerator,
      EQUINOXES_SOLSTICES => EquinoxesSolsticesGenerator,
      GREATEST_ELONGATIONS => GreatestElongationsGenerator,
      LUNAR_ECLIPSES => LunarEclipsesGenerator,
      MOON_PHASES => MoonPhasesGenerator,
      MOON_PLANET_CONJUNCTIONS => MoonPlanetConjunctionsGenerator,
      OPPOSITIONS => OppositionsGenerator,
      PLANETARY_CONJUNCTIONS => PlanetaryConjunctionsGenerator,
      MOON_APOGEES_PERIGEES => MoonApogeesPerigeesGenerator
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
