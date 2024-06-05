Rails.application.routes.draw do
    root "api/v1/transactions#index"
    # Endpoint CRUD

    namespace :api do
        namespace :v1 do
            resources :categories
            resources :transactions
        end
    end

end
