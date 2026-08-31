# frozen_string_literal: true

module CelestialEvents
  class Generator
    EVENT_TYPES = [
      GREATEST_ELONGATIONS = :greatest_elongations,
      LUNAR_ECLIPSES = :lunar_eclipses,
      MOON_PHASES = :moon_phases,
      OPPOSITIONS = :oppositions
    ].freeze

    GENERATORS = {
      GREATEST_ELONGATIONS => GreatestElongationsGenerator,
      LUNAR_ECLIPSES => LunarEclipsesGenerator,
      MOON_PHASES => MoonPhasesGenerator,
      OPPOSITIONS => OppositionsGenerator
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
