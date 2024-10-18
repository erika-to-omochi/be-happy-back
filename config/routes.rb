Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  namespace :api do
    resources :memories do
      member do
        post 'transform'
      end
    end
  end
end
