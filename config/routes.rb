Rails.application.routes.draw do
#   root "sessions#home"
    # Endpoint CRUD

    devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

    namespace :api do
        namespace :v1 do
            resources :categories
            resources :transactions
            resources :users
        end
    end

end
