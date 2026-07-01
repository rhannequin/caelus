# frozen_string_literal: true

class LocationController < ApplicationController
  LATITUDE_RANGE = -90.0..90.0
  LONGITUDE_RANGE = -180.0..180.0
  VALID_TIME_ZONES = ActiveSupport::TimeZone
    .all
    .map { |tz| tz.tzinfo.name }
    .compact
    .to_set
    .freeze

  before_action :require_cookie_consent, only: :update

  def edit
    @latitude = @observer.latitude.degrees.round(4)
    @longitude = @observer.longitude.degrees.round(4)
    @time_zone_name = @observer.time_zone&.name
  end

  def update
    changed = false

    if valid_latitude?(params[:latitude]) && valid_longitude?(params[:longitude])
      cookies.permanent.signed[:latitude] = params[:latitude].to_f
      cookies.permanent.signed[:longitude] = params[:longitude].to_f
      changed = true
    end

    if valid_time_zone?(params[:time_zone])
      cookies.permanent.signed[:time_zone] = params[:time_zone]
      changed = true
    end

    if changed
      track_feature("location_change")
    else
      track_invalid_submission("location")
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def valid_latitude?(latitude)
    return false if latitude.blank?

    LATITUDE_RANGE.include?(latitude.to_f)
  end

  def valid_longitude?(longitude)
    return false if longitude.blank?

    LONGITUDE_RANGE.include?(longitude.to_f)
  end

  def valid_time_zone?(time_zone)
    return false if time_zone.blank?

    time_zone.in?(VALID_TIME_ZONES)
  end
end
