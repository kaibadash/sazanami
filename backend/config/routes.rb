Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      get 'health_checks', to: 'health_checks#index'
      
      # コスト記録API
      post 'categories/:category_name/metrics/:metric_name', to: 'metrics#create'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
