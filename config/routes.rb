Rails.application.routes.draw do
  resources :collectibles
  resources :categories
  resources :reserves
  resources :downloads, except: :new

  devise_for :users

  root 'collectibles#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
