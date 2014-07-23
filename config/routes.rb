Rails.application.routes.draw do
  resources :categories

  resources :events

  #devise
  devise_for :users

  #user
    get '/users/index' => 'users#index', as: 'users'
    get '/users/:id' => 'users#show', as: 'user'
  #static page
    get '/about'    => 'high_voltage/pages#show', id: 'about'
    get '/contact'  => 'high_voltage/pages#show', id: 'contact'
    get '/privacy'  => 'high_voltage/pages#show', id: 'privacy'
    get '/terms'    => 'high_voltage/pages#show', id: 'terms'

    get '/home', to: redirect('/')
  #calendar
    get '/calendar' => 'events#calendar', as: 'calendar'
  #attend event
    get '/events/attend/:event_id/:status' => 'events#attend', as: 'attend_event'
  #cancel event
    get '/events/cancel/:event_id/:status' => 'events#cancel', as: 'cancel_event'

    #root :to => 'high_voltage/pages#show', id: 'home'
    root :to => 'events#calendar'
end
