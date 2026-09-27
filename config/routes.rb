Rails.application.routes.draw do
  get "/health", to: "health#show"
  root "enquiries#new"
  resources :enquiries, only: [:new, :create]
end
