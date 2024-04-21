# frozen_string_literal: true

Rails.application.routes.draw do
  get 'home/index'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'
  post 'deploy', to: 'home#deploy'

  resources :profile, only: %i[index show]

  get 'post/liked', to: 'post#liked'
  get 'post/video_viewed', to: 'post#video_viewed'
  get 'post/commented', to: 'post#commented'
  resources :post, only: %i[index show]

  get 'category/:category_id', to: 'category#show', as: :category_show
end
