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
  resources :tags, only: %i[index show]

  # Redirect old singular route to new plural route
  get '/profile/:id', to: redirect('/profiles/%{id}')

  get 'posts/liked', to: 'posts#liked'
  get 'posts/video_viewed', to: 'posts#video_viewed'
  get 'posts/commented', to: 'posts#commented'
  resources :posts, only: %i[index show]

  get 'category/:category_id', to: 'category#show', as: :category_show

  # API Routes
  namespace :api do
    namespace :v1 do
      # GET /api/v1/profiles/search - Buscar perfiles
      get 'profiles/search', to: 'profiles#search'
      
      # GET /api/v1/profiles/:username - Retorna datos del perfil
      get 'profiles/:username', to: 'profiles#show'
      
      # GET /api/v1/profiles/:username/posts - Retorna los últimos 100 posteos del perfil
      get 'profiles/:username/posts', to: 'posts#index'
    end
  end
end
