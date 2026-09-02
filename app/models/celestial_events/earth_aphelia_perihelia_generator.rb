# frozen_string_literal: true

module CelestialEvents
  class EarthApheliaPeriheliaGenerator
    ApsisEvent = Struct.new(:kind, :instant)

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def generate
      astronoby_events.each do |apsis_event|
        CelestialEvent.create!(
          kind: apsis_event.kind,
          peak_tt: apsis_event.instant.tt
        )
      end
    end

    private

    def astronoby_events
      aphelia + perihelia
    end

    def aphelia
      apsides(:apoapsis_events_between, CelestialEvent::EARTH_APHELION)
    end

    def perihelia
      apsides(:periapsis_events_between, CelestialEvent::EARTH_PERIHELION)
    end

    def apsides(event_type, kind)
      extremum_calculator
        .public_send(event_type, @start_date, @end_date)
        .map { |event| ApsisEvent.new(kind, event.instant) }
    end

    def extremum_calculator
      @extremum_calculator ||= Astronoby::ExtremumCalculator.new(
        body: Earth.planet_class,
        primary_body: Sun.planet_class,
        ephem: SPK.inpop19a
      )
    end
  end
end
