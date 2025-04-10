Rails.application.routes.draw do
  devise_scope :user do
    resource(
      :registration,
      only: %i[edit update],
      controller: "users/registrations",
      as: :user_registration,
      path: "users"
    )
  end

  devise_for :users,
             controllers: { invitations: "users/invitations" },
             skip: :registrations

  get "dashboard", to: "dashboard/broadcasts#index", as: :user_root
  root to: "dashboard/broadcasts#index"

  namespace :admin do
    mount(PgHero::Engine, at: "pghero")
  end

  namespace "dashboard" do
    root to: "broadcasts#index"
    resources :access_tokens, only: :index
    resource :account, only: %i[edit update]

    resources :beneficiaries, only: %i[index show destroy]

    resources :broadcasts do
      resources :alerts, only: %i[index show]
    end

    resources :users, except: %i[new create]
    resource :locale, only: :update
  end

  namespace :v1, module: "api/v1", as: "api_v1", defaults: { format: "json" } do
    resources :broadcasts, only: [ :index, :show, :create, :update ] do
      resources :alerts, controller: "broadcasts/alerts", only: [ :index, :show ] do
        get "stats" => "broadcasts/alerts/stats#index", on: :collection
      end
    end

    resources :beneficiaries, only: [ :index, :create, :show, :update, :destroy ] do
      get "stats" => "beneficiaries/stats#index", on: :collection
      resources :addresses, only: [ :index, :create, :show, :destroy ]
    end

    resource :account, only: :show
  end

  namespace :somleng_webhooks do
    resources :delivery_attempts, only: [] do
      resources :call_status_callbacks, only: :create
    end
  end

  namespace "api", defaults: { format: "json" } do
    resources :callouts, only: [ :show, :index, :create ] do
      resources :callout_participations, only: :index
      resources :callout_events, only: :create
    end

    resources :batch_operations, only: [ :create, :show ] do
      resources :batch_operation_events, only: :create
    end
  end
end
