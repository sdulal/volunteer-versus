Rails.application.routes.draw do

  root                 'static_pages#home'
  get     'about'   => 'static_pages#about'
  get     'contact' => 'static_pages#contact'
  get     'signup'  => 'users#new'
  get     'login'   => 'sessions#new'
  post    'login'   => 'sessions#create'
  delete  'logout'  => 'sessions#destroy'

  resources :users do
    member do
      get :groups, :events
    end
  end

  resources :groups, shallow: true do
    get :members
    resources :events do
      resources :attendances,     except: [:show, :new]
    end
  end

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :memberships,         only: [:create, :update, :destroy]

end
