Rails.application.routes.draw do
  
  resources :products

  devise_for :users
  
  devise_scope :user do
    get "sign_in", to: "devise/sessions#new"
    root :to => "devise/sessions#new"
  end
  
  
  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: { sessions: "api/v1/sessions", registrations: "api/v1/registrations" }
      resources :products, except: [:new, :edit]
    end
  end
  
end
