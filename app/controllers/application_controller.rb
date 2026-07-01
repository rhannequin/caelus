# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Trackable

  # Only allow modern browsers supporting webp images, web push, badges, import
  # maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  DEFAULT_LOCATION = [48.85341, 2.3488] # Paris, France
  DEFAULT_TIME_ZONE = "Europe/Paris"

  around_action :set_observer_and_time
  around_action :set_breadcrumbs

  helper_method :cookie_consent_given?,
    :cookie_consent_chosen?,
    :custom_time?,
    :observer_cache_key,
    :observer_daily_cache_key,
    :observer_yearly_cache_key,
    :observer_end_of_day,
    :observer_end_of_year

  private

  def set_observer_and_time(&block)
    if cookie_consent_given?
      latitude = (cookies.signed[:latitude] || DEFAULT_LOCATION.first).to_f
      longitude = (cookies.signed[:longitude] || DEFAULT_LOCATION.second).to_f
      time_zone = cookies.signed[:time_zone] || DEFAULT_TIME_ZONE
      Time.zone = time_zone
      time = if cookies.signed[:time].present?
        Time.zone.parse(cookies.signed[:time])
      else
        Time.current
      end
    else
      latitude = DEFAULT_LOCATION.first
      longitude = DEFAULT_LOCATION.second
      time_zone = DEFAULT_TIME_ZONE
      Time.zone = time_zone
      time = Time.current
    end

    astronoby_observer = Astronoby::Observer.new(
      latitude: Astronoby::Angle.from_degrees(latitude),
      longitude: Astronoby::Angle.from_degrees(longitude),
      utc_offset: Time.find_zone(time_zone)&.formatted_offset
    )
    @observer = Observer.new(
      astronoby_observer: astronoby_observer,
      time_zone: Time.find_zone(time_zone)
    )
    @time = time
    Time.use_zone(time_zone, &block)
  end

  def set_breadcrumbs
    Appsignal.add_breadcrumb(
      "Context",
      "Observer",
      "",
      {
        "latitude" => @observer.latitude.degrees.to_s,
        "longitude" => @observer.longitude.degrees.to_s,
        "time_zone" => @observer.time_zone.tzinfo.name,
        "time" => @time.iso8601
      }
    )
    yield
  end

  def observer_cache_key
    @observer_cache_key ||=
      "#{@observer.latitude.degrees.round(3)}/" \
        "#{@observer.longitude.degrees.round(3)}/" \
        "#{@observer.time_zone.tzinfo.name}"
  end

  def observer_daily_cache_key
    @observer_daily_cache_key ||= "#{observer_cache_key}/#{@time.to_date}"
  end

  def observer_yearly_cache_key
    @observer_yearly_cache_key ||= "#{observer_cache_key}/#{@time.year}"
  end

  def observer_end_of_day
    Time.current.end_of_day
  end

  def observer_end_of_year
    Time.current.end_of_year
  end

  def cookie_consent_given?
    cookies.signed[:cookie_consent] == "true"
  end

  def cookie_consent_chosen?
    cookies.signed[:cookie_consent].present?
  end

  def custom_time?
    cookies.signed[:time].present?
  end

  def spk
    @spk ||= SPK.for_time(@time)
  end

  def require_cookie_consent
    redirect_back(fallback_location: root_path) unless cookie_consent_given?
  end
end
