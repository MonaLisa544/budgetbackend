Rails.application.routes.draw do
    root "transactions#index"
    # Endpoint CRUD

    resources :categories
    resources :transactions

    namespace :api do
        namespace :v1 do
            resources :categories
            resources :transactions
        end
    end

end
