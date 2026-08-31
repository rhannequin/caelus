# frozen_string_literal: true

module CelestialEvents
  class MoonPhasesGenerator
    def initialize(start_date, end_date)
      @start_date = start_date
      @end_date = end_date
    end

    def generate
      astronoby_events.each do |moon_phase|
        CelestialEvent.create!(
          kind: moon_phase.phase.to_s,
          peak_tt: Astronoby::Instant.from_time(moon_phase.time).tt
        )
      end
    end

    private

    def astronoby_events
      months.flat_map { |month| generate_phases_for_month(month) }
    end

    def generate_phases_for_month(month)
      Astronoby::Moon.monthly_phase_events(
        year: month.year,
        month: month.month
      )
    end

    def months
      month = @start_date.to_date.beginning_of_month
      last_month = @end_date.to_date.beginning_of_month

      [].tap do |months|
        while month <= last_month
          months << month
          month = month.next_month
        end
      end
    end
  end
end
