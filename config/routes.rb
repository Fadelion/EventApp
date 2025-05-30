Rails.application.routes.draw do
  devise_for :users
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "events#index"

  resources :users, only: [:show]
  
  resources :events do
    resources :attendances, only: [:new, :create, :index]
  end
  
  # Routes pour Stripe webhook
  post '/stripe-webhook', to: 'stripe_webhooks#create'
end
