# frozen_string_literal: true

if ENV["APPSIGNAL_PUSH_API_KEY"].present?
  Appsignal.configure do |config|
    config.activate_if_environment(:production)
    config.push_api_key = ENV["APPSIGNAL_PUSH_API_KEY"]
  end
end
