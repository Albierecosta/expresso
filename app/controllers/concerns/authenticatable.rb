module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_current_attributes
  end

  private

  def set_current_attributes
    Current.user       = current_user
    Current.request_id = request.request_id
    Current.user_agent = request.user_agent
    Current.ip_address = request.remote_ip
  end
end
