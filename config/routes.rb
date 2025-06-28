Rails.application.routes.draw do
  # Health check endpoint
  scope :api do
    get 'health_check', to: 'health_check#show'
  end

  root "health_check#show"

  get "/auth/google_oauth2/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/dashboard", to: "uploads#index"

  resources :uploads, only: [:new, :create, :show] do
    get :download, on: :member
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "articles#index"
end
