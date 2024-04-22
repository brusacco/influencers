# frozen_string_literal: true

Rails.application.routes.draw do
  get 'home/index'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'
  post 'deploy', to: 'home#deploy'

  resources :profiles, only: %i[index show]

  # Redirect old singular route to new plural route
  get '/profile/:id', to: redirect('/profiles/%{id}')

  get 'posts/liked', to: 'posts#liked'
  get 'posts/video_viewed', to: 'posts#video_viewed'
  get 'posts/commented', to: 'posts#commented'
  resources :posts, only: %i[index show]

  get 'category/:category_id', to: 'category#show', as: :category_show
end
