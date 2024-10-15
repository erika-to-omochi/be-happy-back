Rails.application.routes.draw do
  resources :memories, only: [:index, :create] do
    member do
      post 'transform'
    end
  end
end
