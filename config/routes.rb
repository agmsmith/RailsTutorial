Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'

  resources :users
  # So /users shows all, /users/1 shows user with ID 1, /users/new makes one,
  # /usr/1/edit, POST /Users, PATCH and DELETE /users/1 do stuff, etc.
end
