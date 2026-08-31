# frozen_string_literal: true

class AlmanacController < ApplicationController
  LOOKAHEAD = 1.year

  def show
    @events = CelestialEvent
      .between(@time, @time + LOOKAHEAD)
      .chronological
    @events_by_month = @events
      .group_by { |event| event.peak_at.in_time_zone.beginning_of_month }

    track_page_view("almanac")
  end
end
