# frozen_string_literal: true

module CelestialEvents
  class Generator
    EVENT_TYPES = [
      OPPOSITIONS = :oppositions
    ].freeze

    GENERATORS = {
      OPPOSITIONS => OppositionsGenerator
    }.freeze

    def initialize(event_type, start_date, end_date)
      @event_type = event_type
      @start_date = start_date
      @end_date = end_date
    end

    def generate
      ensure_event_type!

      generator_class = GENERATORS[@event_type]
      generator = generator_class.new(@start_date, @end_date)
      generator.generate
    end

    private

    def ensure_event_type!
      unless EVENT_TYPES.include?(@event_type)
        raise ArgumentError, "Unsupported event type: #{@event_type}"
      end
    end
  end
end
