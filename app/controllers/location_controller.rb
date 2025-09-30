# frozen_string_literal: true

class LocationController < ApplicationController
  def edit
    @latitude = @observer.latitude.degrees.round(4)
    @longitude = @observer.longitude.degrees.round(4)
    @utc_offset = @observer.utc_offset
  end

  def update
    return redirect_back(fallback_location: root_path) unless cookie_consent_given?

    cookies.permanent.signed[:latitude] = params[:latitude]
    cookies.permanent.signed[:longitude] = params[:longitude]

    if valid_utc_offset?(params[:utc_offset])
      cookies.permanent.signed[:utc_offset] = params[:utc_offset]
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def valid_utc_offset?(utc_offset)
    return false unless utc_offset.present?

    utc_offset.match?(/^[+-](0[0-9]|1[0-2]):(00|15|30|45)$/)
  end

  helper_method :utc_offset_options

  def utc_offset_options
    options = []

    (-12...0).each do |hour|
      [45, 30, 15, 0].each do |minute|
        next if hour == -12 && minute > 0 # Skip -12:15, -12:30, -12:45

        options << formatted_utc_offset_option(hour, minute)
      end
    end
    (0..12).each do |hour|
      [0, 15, 30, 45].each do |minute|
        next if hour == 12 && minute > 0 # Skip +12:15, +12:30, +12:45

        options << formatted_utc_offset_option(hour, minute)
      end
    end

    options
  end

  def formatted_utc_offset_option(hour, minute)
    sign = (hour >= 0) ? "+" : "-"
    abs_hour = hour.abs
    formatted_hour = abs_hour.to_s.rjust(2, "0")
    formatted_minute = minute.to_s.rjust(2, "0")

    value = "#{sign}#{formatted_hour}:#{formatted_minute}"
    display = "#{sign}#{formatted_hour}:#{formatted_minute}"

    [display, value]
  end
end
