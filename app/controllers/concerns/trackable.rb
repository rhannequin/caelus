# frozen_string_literal: true

module Trackable
  extend ActiveSupport::Concern

  private

  def track_page_view(page)
    Appsignal.increment_counter("page_view", 1, page: page)

    if personalized_location?
      Appsignal.increment_counter("personalized_location_view", 1)
    end

    Appsignal.increment_counter("custom_time_view", 1) if custom_time?
  end

  def track_feature(feature)
    Appsignal.increment_counter("feature_usage", 1, feature: feature)
  end

  def track_consent(decision)
    Appsignal.increment_counter("consent", 1, decision: decision)
  end

  def track_invalid_submission(form)
    Appsignal.increment_counter("invalid_submission", 1, form: form)
  end

  def personalized_location?
    cookies.signed[:latitude].present?
  end
end
