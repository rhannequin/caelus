# frozen_string_literal: true

module CelestialEvents
  class LunarEclipsesGenerator
    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def generate
      astronoby_events.each do |lunar_eclipses|
        CelestialEvent.create!(
          kind: CelestialEvent::LUNAR_ECLIPSE,
          peak_tt: lunar_eclipses.instant.tt
        )
      end
    end

    private

    def astronoby_events
      Astronoby::Moon.eclipse_events(
        ephem: SPK.inpop19a,
        start_time: @start_date,
        end_time: @end_date
      )
    end
  end
end
