Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    root to: "home#show"
    resources :freights do
      member { get :print }
    end
  end

  # Public, token-protected recipient flow. Full implementation arrives in
  # Phase 5; the show stub already wires the QR target.
  scope :d, controller: "public/deliveries", as: :public do
    get ":token", action: :show, as: :delivery
  end

  # Health check for uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/admin")
end
