# frozen_string_literal: true

module CelestialEvents
  class EquinoxesSolsticesGenerator
    SeasonEvent = Struct.new(:kind, :time)

    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def generate
      astronoby_events.each do |season_event|
        CelestialEvent.create!(
          kind: season_event.kind,
          peak_tt: Astronoby::Instant.from_time(season_event.time).tt
        )
      end
    end

    private

    def astronoby_events
      years
        .flat_map { |year| generate_seasons_for_year(year) }
        .select { |season_event| covered?(season_event.time) }
    end

    def generate_seasons_for_year(year)
      CelestialEvent::SEASON_KINDS.map do |kind|
        SeasonEvent.new(kind, season_time(kind, year))
      end
    end

    def season_time(kind, year)
      Astronoby::EquinoxSolstice.public_send(kind, year, SPK.inpop19a)
    end

    def years
      (@start_date.year..@end_date.year)
    end

    def covered?(time)
      time.between?(@start_date, @end_date)
    end
  end
end
