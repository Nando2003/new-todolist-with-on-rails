Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  
  post "signup", controller: "auth", action: "signup"
  post "login", controller: "auth", action: "login"
  post "refresh", controller: "auth", action: "refresh"

  get "me", controller: "users", action: "me"

  post "tasks", controller: "tasks", action: "create"
  get "tasks/:id", controller: "tasks", action: "show"
  get "tasks", controller: "tasks", action: "index"
  put "tasks/:id", controller: "tasks", action: "update"
  delete "tasks/:id", controller: "tasks", action: "delete"
end
