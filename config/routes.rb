Rails.application.routes.draw do
  namespace :api do
    resources :memories do
      member do
        post 'transform'
      end
    end
  end
end
