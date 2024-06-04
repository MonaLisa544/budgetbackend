Rails.application.routes.draw do
    root "transactions#index"
    # Endpoint CRUD

    namespace :api do
        namespace :v1 do
            resources :categories
            resources :transactions
        end
    end

end
