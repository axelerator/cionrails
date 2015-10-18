Rails.application.routes.draw do
  resource :configuration, only: [:new, :show, :create] do
    post :reset, as: :reset
  end
  resources :builds
  root to: 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
