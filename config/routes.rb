# uncomment this and the mount instruction below to add queue monitoring to the app
# require 'sidekiq/web'

Rails.application.routes.draw do
  get "users/:id/cars/recommended", controller: "users", action: :show_recommended_cars
  match "user_car_recommendations", to: 'user_recommended_cars#show', via: [:query, :post]


  # mount Sidekiq::Web => '/sidekiq'
end
