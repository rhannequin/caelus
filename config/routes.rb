# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"

  resource :location, only: [:edit, :update], controller: :location
  resource :time, only: [:edit, :update, :destroy], controller: :time

  resource :almanac, only: [:show], controller: :almanac
  resources :lunar_eclipses, only: [:index, :show]
  resource :moon, only: [:show], controller: :moon
  resource :sun, only: [:show], controller: :sun

  resource :privacy_policy, only: :show, controller: :privacy_policy
  resource :cookie_consent,
    only: [:create, :destroy, :new],
    controller: :cookie_consent

  get "/sitemap.xml",
    to: "sitemaps#show",
    as: :sitemap,
    defaults: {format: "xml"}

  get "up" => "rails/health#show", :as => :rails_health_check
end
