# frozen_string_literal: true

class TimeController < ApplicationController
  TIME_RANGE = Time.utc(1900, 1, 1)...Time.utc(2100, 1, 1)

  before_action :require_cookie_consent, only: :update

  def edit
  end

  def update
    if valid_time?(params[:time])
      cookies.permanent.signed[:time] =
        Time.zone.parse(params[:time]).utc.iso8601
      track_feature("time_travel")
    else
      track_invalid_submission("time")
    end

    redirect_back(fallback_location: root_path)
  end

  def destroy
    if cookie_consent_given?
      cookies.delete(:time)
      track_feature("time_travel_reset")
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def valid_time?(time)
    return false if time.blank?

    parsed_time = Time.zone.parse(time)
    parsed_time&.utc&.in?(TIME_RANGE) || false
  rescue ArgumentError, TypeError
    false
  end
end
