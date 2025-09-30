# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import
  # maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  DEFAULT_LOCATION = [48.85341, 2.3488] # Paris, France
  DEFAULT_TIME_ZONE = "Europe/Paris"

  before_action :set_observer

  helper_method :cookie_consent_given?,
    :cookie_consent_chosen?,
    :observer_cache_key,
    :observer_end_of_day,
    :observer_end_of_year

  private

  def default_utc_offset
    Time
      .zone
      .now
      .in_time_zone(DEFAULT_TIME_ZONE)
      .formatted_offset
  end

  def set_observer
    if cookie_consent_given?
      latitude = (cookies.signed[:latitude] || DEFAULT_LOCATION.first).to_f
      longitude = (cookies.signed[:longitude] || DEFAULT_LOCATION.second).to_f
      utc_offset = cookies.signed[:utc_offset] || default_utc_offset
    else
      latitude = DEFAULT_LOCATION.first
      longitude = DEFAULT_LOCATION.second
      utc_offset = default_utc_offset
    end

    @observer = Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(latitude),
      longitude: Astronoby::Angle.from_degrees(longitude),
      utc_offset: utc_offset
    )
  end

  def observer_cache_key
    "#{@observer.latitude.degrees.round(3)}/" \
      "#{@observer.longitude.degrees.round(3)}/" \
      "#{@observer.utc_offset}"
  end

  def observer_end_of_day
    Time.now.getlocal(@observer.utc_offset).end_of_day
  end

  def observer_end_of_year
    Time.now.getlocal(@observer.utc_offset).end_of_year
  end

  def cookie_consent_given?
    cookies.signed[:cookie_consent] == "true"
  end

  def cookie_consent_chosen?
    cookies.signed[:cookie_consent].present?
  end
end
