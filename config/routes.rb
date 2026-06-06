Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    root to: "home#show"

    resources :freights do
      member do
        get :print
        get :receipt
      end
    end
    resources :clients
    resources :recipients
    resources :drivers
    resources :reports, only: :index do
      collection do
        get :monthly
        get :monthly_pdf
      end
    end
    resource :company, only: %i[show edit update]
  end

  # Public, token-protected recipient flow.
  scope :d, controller: "public/deliveries", as: :public do
    get  ":token",           action: :show,         as: :delivery
    get  ":token/photo",     action: :photo,        as: :delivery_photo
    post ":token/photo",     action: :upload_photo
    get  ":token/signature", action: :signature,    as: :delivery_signature
    post ":token/signature", action: :sign
    get  ":token/done",      action: :done,         as: :delivery_done
  end

  # Health check for uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/admin")
end
