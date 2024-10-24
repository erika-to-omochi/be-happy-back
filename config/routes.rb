Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json }, controllers: {
    sessions: 'api/users/sessions',
    registrations: 'api/users/registrations'
  }

  namespace :api do
    devise_scope :user do
      post 'login', to: 'users/sessions#create'
      post 'signup', to: 'users/registrations#create'
      delete 'logout', to: 'users/sessions#destroy'
      post 'guest_sessions', to: 'guest_sessions#create'
    end

    resources :memories do
      member do
        post 'transform'
      end
      collection do
        get 'my_page', to: 'memories#my_page'
      end
    end

    match '*path', to: 'application#options', via: [:options]
  end
end
