Rails.application.routes.draw do
  root to: 'welcome#index'

  resources :items, only: [:index, :show], param: :slug
  resources :merchants, only: [:index]

  get '/cart', to: 'cart#index'
  post '/cart/additem/:slug', to: 'cart#add_item', as: 'cart_add_item'
  post '/cart/addmoreitem/:slug', to: 'cart#add_more_item', as: 'cart_add_more_item'
  delete '/cart', to: 'cart#destroy', as: 'cart_empty'
  delete '/cart/item/:slug', to: 'cart#remove_more_item', as: 'cart_remove_more_item'
  delete '/cart/item/:slug/all', to: 'cart#remove_all_of_item', as: 'cart_remove_item_all'

  get '/login', to: 'session#new'
  post '/login', to: 'session#create'
  get '/logout', to: 'session#destroy'

  get '/register', to: 'users#new', as: 'registration'
  resources :users, only: [:create, :update], param: :slug

  get '/dashboard', to: 'merchants#show', as: 'dashboard'
  namespace :dashboard do
    resources :orders, only: [:show] do
      patch '/items/:slug/fulfill', to: 'orders#fulfill_item', as: 'item_fulfill'
    end
    resources :items, except: [:show], param: :slug
    patch '/items/:slug/enable', to: 'items#enable', as: 'enable_item'
    patch '/items/:slug/disable', to: 'items#disable', as: 'disable_item'
  end
  get '/profile', to: 'profile#index', as: 'profile'

  get '/profile/edit', to: 'users#edit'
  namespace :profile do
    resources :reviews, only: [:index]
    resources :orders, only: [:index, :create, :show, :destroy] do
      get '/order_item/:id/review/new', to: 'reviews#new', as: 'new_review'
      post '/order_item/:id/review', to: 'reviews#create', as: 'order_item_reviews'
      delete '/order_item/:id/review/:id', to: 'reviews#destroy', as: 'delete_item_review'
      get '/order_item/:id/review/:id/edit', to:'reviews#edit', as: 'edit_review'
      patch '/order_item/:id/review/:id', to: 'reviews#update', as: 'order_item_review'
    end
  end

  post '/admin/users/:merchant_slug/items', to: 'dashboard/items#create', as: 'admin_user_items'
  patch '/admin/users/:merchant_slug/items/:slug', to: 'dashboard/items#update', as: 'admin_user_item'
  namespace :admin do
    resources :users, only: [:index, :show, :edit], param: :slug do
      patch '/enable', to: 'users#enable', as: 'enable'
      patch '/disable', to: 'users#disable', as: 'disable'
      patch '/upgrade', to: 'users#upgrade', as: 'upgrade'
      resources :orders, only: [:index, :show]
    end
    resources :merchants, only: [:show], param: :slug do
      patch '/enable', to: 'merchants#enable', as: 'enable'
      patch '/disable', to: 'merchants#disable', as: 'disable'
      patch '/upgrade', to: 'merchants#downgrade', as: 'downgrade'
      resources :items, only: [:index, :new, :edit], param: :slug
    end
    resources :dashboard, only: [:index]
  end
end
