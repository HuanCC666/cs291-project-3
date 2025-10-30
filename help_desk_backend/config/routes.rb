Rails.application.routes.draw do
  namespace :api do
    get "updates/conversations"
    get "updates/messages"
    get "updates/expert_queue"
  end
  get "expert/queue"
  get "expert/claim"
  get "expert/unclaim"
  get "expert/profile"
  get "expert/update_profile"
  get "expert/assignments_history"
  get "messages/index"
  get "messages/create"
  get "messages/read"
  get "conversations/index"
  get "conversations/show"
  get "conversations/create"
  get "auth/register"
  get "auth/login"
  get "auth/logout"
  get "auth/refresh"
  get "auth/me"
  get "health/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
