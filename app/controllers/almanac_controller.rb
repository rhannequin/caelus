# frozen_string_literal: true

class AlmanacController < ApplicationController
  LOOKAHEAD = 1.year

  def show
    @events = notable_events
    @events_by_month = group_by_month(@events)
    @moon_phases_by_month = group_by_month(moon_phases)
    @months = (@events_by_month.keys | @moon_phases_by_month.keys).sort

    track_page_view("almanac")
  end

  private

  def notable_events
    CelestialEvent.notable.between(@time, @time + LOOKAHEAD).chronological
  end

  def moon_phases
    CelestialEvent
      .moon_phases
      .between(@time.beginning_of_month, (@time + LOOKAHEAD).end_of_month)
      .chronological
  end

  def group_by_month(scope)
    scope.group_by { |event| event.peak_at.in_time_zone.beginning_of_month }
  end
end
