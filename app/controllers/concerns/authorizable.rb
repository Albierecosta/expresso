module Authorizable
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization

    # Conditional callbacks instead of `only:` so the controller doesn't have
    # to define every action listed there (Rails 7.1+ raises on missing actions).
    after_action :verify_authorized, unless: :index_action?
    after_action :verify_policy_scoped, if: :index_action?

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  private

  def index_action?
    action_name == "index"
  end

  def user_not_authorized
    flash[:alert] = I18n.t("flash.not_authorized")
    redirect_back(fallback_location: root_path)
  end
end
