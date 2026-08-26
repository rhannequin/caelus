# frozen_string_literal: true

class LunarEclipsesController < ApplicationController
  SUPPORTED_YEARS = (1900..2100)

  def index
    @selected_year = selected_year
    @supported_years = SUPPORTED_YEARS
    start_time = Time.utc(@selected_year)
    @lunar_eclipses = Astronoby::Moon.eclipse_events(
      ephem: SPK.for_time(start_time),
      start_time: start_time,
      end_time: start_time.end_of_year
    )

    track_page_view("lunar_eclipses")
  end

  def show
    @date = Date.iso8601(params[:id])

    raise Caelus::NotFound unless SUPPORTED_YEARS.cover?(@date.year)

    time_utc = Time.utc(@date.year, @date.month, @date.day)
    @lunar_eclipse = Astronoby::Moon.eclipse_events(
      ephem: SPK.for_time(time_utc),
      start_time: time_utc.beginning_of_day,
      end_time: time_utc.end_of_day
    ).first

    raise Caelus::NotFound if @lunar_eclipse.nil?

    track_page_view("lunar_eclipse")
  rescue Date::Error
    raise Caelus::NotFound
  end

  private

  def selected_year
    year = params[:year].presence&.to_i || Time.current.year
    year.clamp(SUPPORTED_YEARS.first, SUPPORTED_YEARS.last)
  end
end
