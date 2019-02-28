Rails.application.routes.draw do
  
  get 'attachmets/new'

  get 'installerschedule/:id', to: 'installer_schedule#show', as: 'installerschedule'
  get 'installerschedule/:id/date/:date', to: 'installer_schedule#show', as: 'installerscheduledate'
  post 'installerscheduleupdate', to: 'installer_schedule#update', as: 'installerscheduleupdate'

  get 'sellerschedule/:id', to: 'seller_schedule#show', as: 'sellerschedule'
  get 'sellerschedule/:id/date/:date', to: 'seller_schedule#show', as: 'sellerscheduledate'
  post 'sellerscheduleupdate', to: 'seller_schedule#update', as: 'sellerscheduleupdate'

  get 'appointments/find', to: 'appointments#search'

  resources :appointments
  resources :administrators
  resources :managers
  resources :sellers
  resources :telemarketers
  resources :installers
  resources :customers
  resources :sessions
  resources :users
  resources :articles

  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'users/password/:id', to: 'users#password', as: 'password'
  get 'logs', to: 'logs#index'
  get 'appointments/new/:unixtime', to: 'appointments#new'
  get 'appointments/date/:date', to: 'appointments#index'
  get 'customers/find/:phone', to: 'customers#find_by_phone'
  get 'bookings/available/:appointment/:date', to: 'appointments#bookings'
  get 'installers/available/:appointment/:date', to: 'installers#available'
  get 'appointments/:id/archive', to: 'appointments#archive'
  get 'appointments/:id/delete', to: 'appointments#delete'
  patch 'users/update_password/:id', to: 'users#update_password', as: 'update_password'
  patch 'users/activate/:id', to: 'users#activate', as: 'user_activate'

  match '/new/:id' => 'attachments#new',   :via => :POST, :as => :new

  root to: 'appointments#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
