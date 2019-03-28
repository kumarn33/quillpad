Rails.application.routes.draw do
  devise_for :users, path: '', path_names: { sign_in: 'login' }

  resources :posts do
    collection do
      post :search
    end

    member do
      get :publish
      get :unpublish
    end
  end

  resource :profiles, only: [:show, :edit, :update]
  resources :blogs, only: [:index, :show]

  get 'about', to: 'pages#show'
  get 'status', controller: 'application', action: 'status'

  # subdomain based access
  match '/' => 'blogs#index', :constraints => { :subdomain => /.+/ }, via: [:get]

  root to: 'pages#index'
end
