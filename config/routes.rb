Rails.application.routes.draw do

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
            resources :transactions
      end
  end
end
