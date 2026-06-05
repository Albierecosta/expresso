class ApplicationController < ActionController::Base
  include Paginatable
  include Searchable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  private

  def after_sign_in_path_for(_resource) = admin_root_path
  def after_sign_out_path_for(_resource) = new_user_session_path
end
