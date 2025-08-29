# config/routes.rb

Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # to does WITHOUT journal
  resources :todos, only: [:index, :new, :create, :edit, :update, :destroy] do
  get 'completed', on: :collection
  end

  # Defines the root path route ("/")
  # to dos through journal entries
  resources :journals, only: [:new, :create, :show] do
    get 'todo_brief', on: :member
    resources :todos, only: [:index, :edit, :update, :destroy] do
      get 'completed', on: :collection
    end
  end
end
