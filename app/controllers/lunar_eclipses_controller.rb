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
end
