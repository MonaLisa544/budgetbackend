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
  post '/users/password_change', to: 'users#password_change'
  patch 'users/player_id', to: 'users#update_player_id'
  

  namespace :api do
      namespace :v1 do
            resources :categories
            resources :goals
            resources :budgets 
            resources :monthly_budgets, only: [:index, :show, :update]
            resources :notifications, only: [:index] do
              member do
                patch :mark_as_read
              end
            end
            resources :families do 
              collection do 
                get 'me', do: "families#me"
                get 'members', do: "families#members"
                post 'join', to: "families#join"
                patch 'change_role', to: "families#change_role"
              end
            end
            namespace :wallets do
              get :me         
              get :family     
              put :update_me         
              put :update_family    
            end
            resources :transactions do
              collection do
                get 'summary', to: "transactions#total_transactions"
                get 'category', to: "transactions#category_transactions"
              end
            end
      end
  end
end
