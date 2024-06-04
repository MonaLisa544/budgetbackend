Rails.application.routes.draw do
  
    # Endpoint CRUD

    # resources :categories
    # resources :transactions

    namespace :api do
        namespace :v1 do
          resources :categories
          resources :transactions
        end
      end

end
