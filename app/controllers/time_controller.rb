# frozen_string_literal: true

class TimeController < ApplicationController
  TIME_RANGE = Time.utc(1900, 1, 1)..Time.utc(2100, 1, 1)

  def edit
  end

  def update
    return redirect_back(fallback_location: root_path) unless cookie_consent_given?

    if valid_time?(params[:time])
      cookies.permanent.signed[:time] = params[:time]
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def valid_time?(time)
    return false if time.blank?

    parsed_time = Time.zone.parse(time)
    parsed_time.in?(TIME_RANGE)
  rescue ArgumentError
    false
  end
end
