Rails.application.routes.draw do
  resources :subscriptions, only: :index
  resources :collectibles do
    member do
      patch 'sort_order_up'
      patch 'sort_order_down'
    end
  end
  resources :categories, except: [:index, :show]
  resources :reserves
  resources :downloads, only: :index

  devise_for :users

  post 'misc/maintenance'

  root 'collectibles#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
