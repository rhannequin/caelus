# frozen_string_literal: true

class LunarEclipsesController < ApplicationController
  SUPPORTED_YEARS = (1900..2100)

  helper_method :lunar_eclipse_cache_key

  def index
    @selected_year = selected_year
    @supported_years = SUPPORTED_YEARS
    @lunar_eclipses = lunar_eclipses(@selected_year)

    track_page_view("lunar_eclipses")
  end

  def show
    @date = Date.iso8601(params[:id])

    raise Caelus::NotFound unless SUPPORTED_YEARS.cover?(@date.year)

    @lunar_eclipse = lunar_eclipses(@date.year).find do |lunar_eclipse|
      helpers.lunar_eclipse_date(lunar_eclipse) == @date
    end

    raise Caelus::NotFound if @lunar_eclipse.nil?

    track_page_view("lunar_eclipse")
  rescue Date::Error
    raise Caelus::NotFound
  end

  private

  def lunar_eclipses(year)
    Rails.cache.fetch(lunar_eclipse_cache_key(year)) do
      start_time = Time.utc(year)
      Astronoby::Moon.eclipse_events(
        ephem: SPK.for_time(start_time),
        start_time: start_time,
        end_time: start_time.end_of_year
      )
    end
  end

  def lunar_eclipse_cache_key(scope)
    "lunar_eclipses/#{Astronoby::VERSION}/#{scope}"
  end

  def selected_year
    year = params[:year].presence&.to_i || Time.current.year
    year.clamp(SUPPORTED_YEARS.first, SUPPORTED_YEARS.last)
  end
end
