Rails.application.routes.draw do

  devise_for :users,
             controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
             }

  namespace :api do
      namespace :v1 do
          resources :users do
            resources :categories
            resources :transactions
          end
      end
  end
end
