Rails.application.routes.draw do

  get 'base_points/new'

  get 'sessions/new'

  root 'sessions#new'
  get '/signup', to: 'users#new'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/edit_overtime_application'
      patch 'attendances/update_overtime_application'
    end

    resources :attendances, only: :update
    collection { post :import}
    collection do
      get :at_work
    end
  end

  resources :base_points, except: :show


  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
