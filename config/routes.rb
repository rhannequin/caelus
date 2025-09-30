# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"

  resource :location, only: [:edit, :update], controller: :location

  resource :moon, only: [:show], controller: :moon
  resource :sun, only: [:show], controller: :sun

  resource :privacy_policy, only: :show, controller: :privacy_policy
  resource :cookie_consent,
    only: [:create, :destroy],
    controller: :cookie_consent

  get "up" => "rails/health#show", :as => :rails_health_check
end
