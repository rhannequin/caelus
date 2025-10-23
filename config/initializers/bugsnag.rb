# frozen_string_literal: true

if ENV["BUGSNAG_API_KEY"].present?
  Bugsnag.configure do |config|
    config.api_key = ENV["BUGSNAG_API_KEY"]

    config.release_stage = Rails.env

    config.notify_release_stages = ["production"]
  end
end
