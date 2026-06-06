# Rate limiting for the public recipient flow and the login endpoint.
# Uses Rails.cache (Solid Cache in this app) as the store.
Rack::Attack.cache.store = Rails.cache

# Throttle public delivery views per IP — 60 reqs/min handles a recipient
# scanning, filling photo, and signing comfortably; blocks scraping bots.
Rack::Attack.throttle("public/delivery/ip", limit: 60, period: 1.minute) do |req|
  req.ip if req.path.start_with?("/d/")
end

# Throttle login attempts per IP and per email — 5 attempts / 20s window.
# Tight enough to slow credential stuffing, generous enough that a typo
# doesn't lock anyone out for long.
Rack::Attack.throttle("sign_in/ip", limit: 5, period: 20.seconds) do |req|
  req.ip if req.path == "/users/sign_in" && req.post?
end

Rack::Attack.throttle("sign_in/email", limit: 5, period: 20.seconds) do |req|
  if req.path == "/users/sign_in" && req.post?
    req.params.dig("user", "email").to_s.downcase.presence
  end
end

# Custom response for throttled clients.
Rack::Attack.throttled_responder = lambda do |request|
  retry_after = (request.env["rack.attack.match_data"] || {})[:period]
  [ 429, { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s },
    [ "Muitas tentativas. Tente novamente em alguns instantes.\n" ] ]
end
