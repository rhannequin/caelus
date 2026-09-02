# frozen_string_literal: true

module CelestialEvents
  class MoonApogeesPerigeesGenerator
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
      apogees + perigees
    end

    def apogees
      apsides(:apoapsis_events, CelestialEvent::MOON_APOGEE)
    end

    def perigees
      apsides(:periapsis_events, CelestialEvent::MOON_PERIGEE)
    end

    def apsides(event_type, kind)
      Astronoby::Moon
        .public_send(
          event_type,
          ephem: SPK.inpop19a,
          start_time: @start_date,
          end_time: @end_date
        )
        .map { |event| ApsisEvent.new(kind, event.instant) }
    end
  end
end
