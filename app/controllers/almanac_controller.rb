# frozen_string_literal: true

class AlmanacController < ApplicationController
  LOOKAHEAD = 1.year

  def show
    @events = notable_events
    @events_by_month = group_by_month(@events)
    @moon_phases_by_month = group_by_month(lunar_rhythm(:moon_phases))
    @moon_apsides_by_month = group_by_month(lunar_rhythm(:moon_apsides))
    @months = (@events_by_month.keys | upcoming_phase_months).sort

    track_page_view("almanac")
  end

  private

  def notable_events
    CelestialEvent.notable.between(@time, @time + LOOKAHEAD).chronological
  end

  def lunar_rhythm(scope)
    CelestialEvent
      .public_send(scope)
      .between(@time.beginning_of_month, (@time + LOOKAHEAD).end_of_month)
      .chronological
  end

  def upcoming_phase_months
    @moon_phases_by_month
      .select { |_, phases| phases.any? { |phase| phase.peak_at >= @time } }
      .keys
  end

  def group_by_month(scope)
    scope.group_by { |event| event.peak_at.in_time_zone.beginning_of_month }
  end
end
