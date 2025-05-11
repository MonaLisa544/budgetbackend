Rails.application.routes.draw do
  post '/password/reset', to: 'password_resets#create'    
  get '/password/reset/edit', to: 'password_resets#edit'    
  patch '/password/reset/edit', to: 'password_resets#update'

 
  devise_for :users,
             controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
              }

  get '/users/me', to: 'users#show'
  put '/users/edit', to: 'users#update'

  namespace :api do
      namespace :v1 do
            resources :categories
            resources :loans
            resources :savings
            resources :families do 
              collection do 
                post 'join', to: "families#join"
                patch 'change_role', to: "families#change_role"
              end
            end
            namespace :wallets do
              get :me         # ①
              get :family     # ②
              put :update_me         # ③
              put :update_family    # ④
            end
            resources :notifications
            resources :budgets
            resources :transactions do
              collection do
                get 'summary', to: "transactions#total_transactions"
                get 'category', to: "transactions#category_transactions"
              end
            end
      end
  end
end
