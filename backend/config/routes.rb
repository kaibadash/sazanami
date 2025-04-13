# frozen_string_literal: true

Rails.application.routes.draw do
  # root "posts#index"
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  get "health_checks", to: "health_checks#index"

  resources :categories, param: :name, only: [] do
    resources :metrics, param: :metric_name, only: %i[index update]
  end
end
