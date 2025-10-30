Rails.application.routes.draw do
  # Health
  get "/health", to: "health#index"

  # Auth (session cookie + JWT token)
  scope :auth do
    post "register", to: "auth#register"
    post "login",    to: "auth#login"
    post "logout",   to: "auth#logout"
    post "refresh",  to: "auth#refresh"
    get  "me",       to: "auth#me"
  end

  # Conversations (JWT)
  resources :conversations, only: [:index, :show, :create] do
    # Messages index under conversation
    resources :messages, only: [:index], controller: "messages"
  end

  # Messages create/read (JWT)
  resources :messages, only: [:create] do
    member { put :read }  # /messages/:id/read
  end

  # Expert (JWT)
  scope :expert do
    get  "queue", to: "expert#queue"
    post "conversations/:conversation_id/claim",   to: "expert#claim"
    post "conversations/:conversation_id/unclaim", to: "expert#unclaim"

    get  "profile", to: "expert#profile"
    put  "profile", to: "expert#update_profile"

    get  "assignments/history", to: "expert#assignments_history"
  end

  # Updates / polling (JWT) —— namespace /api
  namespace :api do
    get "conversations/updates", to: "updates#conversations"
    get "messages/updates",      to: "updates#messages"
    get "expert-queue/updates",  to: "updates#expert_queue"
  end
end
