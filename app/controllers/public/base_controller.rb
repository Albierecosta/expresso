module Public
  # Base controller for the recipient-facing flow (no auth, no Pundit).
  # Uses a mobile-first layout dedicated to the QR scan journey.
  class BaseController < ApplicationController
    layout "public"
  end
end
