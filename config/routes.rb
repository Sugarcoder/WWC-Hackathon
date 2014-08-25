require 'sidekiq/web'

Rails.application.routes.draw do
  resources :locations

  resources :categories

  resources :events

  #devise
  devise_for :users

  #user
  get   '/users/index' => 'users#index', as: 'users'
  get   '/users/:id' => 'users#show', as: 'user'
  get   '/users/:id/avatar' => 'users#avatar', as: 'user_avatar'
  post  '/users/:id/avatar' => 'users#upload_avatar', as: 'upload_avatar'
  get   '/users/:id/events/:type' => 'users#events', as: 'user_events'
  post  '/users/check-username' => 'users#check_username'
  post  '/users/check-email' => 'users#check_email'
  #static page
  get   '/about'    => 'high_voltage/pages#show', id: 'about'
  get   '/contact'  => 'high_voltage/pages#show', id: 'contact'
  get   '/contribute' => 'high_voltage/pages#show', id: 'contribute'
  get   '/contributor'  => 'high_voltage/pages#show', id: 'contributor'
  get   '/contact-us' => 'high_voltage/pages#show', id: 'contact-us'
  get   '/challenge' => 'high_voltage/pages#show', id: 'challenge'
  get   '/donate-funds' => 'high_voltage/pages#show', id: 'donate-funds'
  get   '/donate-food' => 'high_voltage/pages#show', id: 'donate-food'
  get   '/food-waste' => 'high_voltage/pages#show', id: 'food-waste'
  get   '/food-insecurity' => 'high_voltage/pages#show', id: 'food-insecurity'
  get   '/histroy'  => 'high_voltage/pages#show', id: 'history'
  get   '/team'     => 'high_voltage/pages#show', id: 'team'
  get   '/terms'     => 'high_voltage/pages#show', id: 'terms'
  get   '/home' => 'high_voltage/pages#show', id: 'home'
  get   '/policy' => 'high_voltage/pages#show', id: 'policy'
  get   '/volunteer' => 'high_voltage/pages#show', id: 'volunteer'

  

  get   '/home', to: redirect('/')
  #Event
  get   '/calendar(/:type)' => 'events#calendar', as: 'calendar'
  get   '/events/cancel/:id/recurring' => 'events#stop_attend_recurring', as: 'stop_attend_recurring_event'
  get   '/events/attend/:event_id/:status' => 'events#attend', as: 'attend_event'
  get   '/events/cancel/:event_id/:status' => 'events#cancel', as: 'cancel_event'
delete  '/events/recurring/:id' => 'events#stop_recurring', as: 'event_stop_recurring' #stop recurring event
  get   '/events/finish/:id' => 'events#finish_form', as: 'finish_form'  #finish event form
  post  '/events/finish' => 'events#finish', as: 'finish_event' #finish event
  post  '/events/attend/:id/recurring' => 'events#attend_recurring', as: 'attend_recurring_event'

  get   '/events/photos/:id' => 'events#photo', as: 'event_photo'

  #Comment
  post  '/comments' => 'comments#create'
delete  '/comments/:id' => 'comments#destroy'
  get   '/comments/:event_id/:page' => 'comments#loadmore'

  #admin
  get   '/admin' => 'admin#index', as: 'admin'
  post  '/admin/change-user-role' => 'admin#change_user_role', as: 'change_user_role'
  post  '/admin/assign-event' => 'admin#assign_event', as: 'assign_event'

  #search
  get   '/search/users(/:user_type)' => 'search#search_user', as: 'search_user'

  authenticate :user, lambda { |u| u.super_admin? } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end

end
