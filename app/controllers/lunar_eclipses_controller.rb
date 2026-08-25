# frozen_string_literal: true

class LunarEclipsesController < ApplicationController
  def index
    @lunar_eclipses = Astronoby::Moon.eclipse_events(
      ephem: spk,
      start_time: Time.current.beginning_of_year,
      end_time: Time.current.end_of_year
    )

    track_page_view("lunar_eclipses")
  end
end
