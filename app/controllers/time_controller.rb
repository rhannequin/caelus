# frozen_string_literal: true

class TimeController < ApplicationController
  TIME_RANGE = Time.utc(1900, 1, 1)...Time.utc(2100, 1, 1)

  def edit
  end

  def update
    return redirect_back(fallback_location: root_path) unless cookie_consent_given?

    if valid_time?(params[:time])
      cookies.permanent.signed[:time] =
        Time.zone.parse(params[:time]).utc.iso8601
    end

    redirect_back(fallback_location: root_path)
  end

  def destroy
    cookies.delete(:time) if cookie_consent_given?

    redirect_back(fallback_location: root_path)
  end

  private

  def valid_time?(time)
    return false if time.blank?

    parsed_time = Time.iso8601(time)
    parsed_time.in?(TIME_RANGE)
  rescue ArgumentError, TypeError
    false
  end
end
