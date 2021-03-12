Rails.application.routes.draw do

  root 'sessions#new'
  get '/signup', to: 'users#new'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      # 個々の勤怠編集
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      # 残業申請
      get 'attendances/edit_overtime_application'
      patch 'attendances/update_overtime_application'
      # 残業承認
      get 'attendances/edit_overtime_approval'
      patch 'attendances/update_overtime_approval'
      # 1ヶ月の勤怠申請
      get 'attendances/edit_monthly_attendance_application'
      patch 'attendances/update_monthly_attendance_application'
      # 1ヶ月の勤怠承認
      get 'attendances/edit_monthly_attendance_approval'
      patch 'attendances/update_monthly_attendance_approval'
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
