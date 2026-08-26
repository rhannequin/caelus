# frozen_string_literal: true

class LunarEclipsesController < ApplicationController
  def index
    @selected_year = params[:year] || Time.current.year
    @lunar_eclipses = Astronoby::Moon.eclipse_events(
      ephem: spk,
      start_time: Time.new(@selected_year).beginning_of_year,
      end_time: Time.new(@selected_year).end_of_year
    )

    track_page_view("lunar_eclipses")
  end

  def show
    @date = Date.iso8601(params[:id])
    time_utc = Time.utc(@date.year, @date.month, @date.day)
    @lunar_eclipse = Astronoby::Moon.eclipse_events(
      ephem: spk,
      start_time: time_utc.beginning_of_day,
      end_time: time_utc.end_of_day
    ).first

    raise Caelus::NotFound if @lunar_eclipse.nil?

    track_page_view("lunar_eclipse")
  rescue Date::Error
    raise Caelus::NotFound
  end
end
