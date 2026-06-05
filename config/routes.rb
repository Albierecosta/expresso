Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    root to: "home#show"
  end

  # Health check for uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/admin")
end
