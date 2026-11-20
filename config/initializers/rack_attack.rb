# frozen_string_literal: true

class Rack::Attack
  SCANNER_PROBE = %r{
    /\.(?!well-known/)
    | \.(php|asp|aspx|jsp|cgi|ya?ml|ini|sql|bak|log|conf|properties)\z
    | /(wp-|wordpress|phpmyadmin|xmlrpc|cgi-bin)
  }xi

  safelist("allow health checks") do |req|
    req.path == "/up"
  end

  blocklist("ban scanners probing for secrets") do |req|
    Fail2Ban.filter(
      "scanner:#{req.ip}",
      maxretry: 1,
      findtime: 1.minute,
      bantime: 1.hour
    ) { req.path.match?(SCANNER_PROBE) }
  end

  throttle("requests by ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path == "/up"
  end
end
