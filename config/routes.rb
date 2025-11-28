# frozen_string_literal: true

Rails.application.routes.draw do
  get 'home/index'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'
  post 'deploy', to: 'home#deploy'

  # Serve blob files directly from filesystem (for development and production)
  get '/blob_files/:dir1/:dir2/:key', to: 'blob_files#show', constraints: { key: /[^\/]+/ }

  resources :profiles, only: %i[index show]
  resources :tiktok_profiles, only: %i[index show]
  resources :tags, only: %i[index show]

  # Redirect old singular route to new plural route
  get '/profile/:id', to: redirect('/profiles/%{id}')

  get 'posts/liked', to: 'posts#liked'
  get 'posts/video_viewed', to: 'posts#video_viewed'
  get 'posts/commented', to: 'posts#commented'
  resources :posts, only: %i[index show]

  get 'category/:category_id', to: 'category#show', as: :category_show

  # Company Pages
  get 'acerca-de', to: 'pages#about', as: :about

  # Legal Pages
  get 'privacidad', to: 'legal#privacy', as: :privacy
  get 'terminos', to: 'legal#terms', as: :terms

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

  # Error Pages (must be at the end)
  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
