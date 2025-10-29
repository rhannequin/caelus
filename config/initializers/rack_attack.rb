# frozen_string_literal: true

class Rack::Attack
  safelist("allow health checks") do |req|
    req.path == "/up"
  end

  throttle("requests by ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path == "/up"
  end
end
