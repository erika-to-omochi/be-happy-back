Rails.application.routes.draw do
  resources :memories, only: [:create, :transform] do
    member do
      post 'transform'
    end
  end
end
