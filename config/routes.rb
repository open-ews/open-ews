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

    namespace :settings do
      root to: "accounts#show"

      resource :account, only: [ :show, :update ]
      resources :users, only: [ :index, :show ]
      resources :developers, only: :index
    end

    resources :beneficiaries
    resources :beneficiary_addresses, only: :new

    resources :broadcasts do
      resource :state, only: :create, controller: "broadcasts/states"
      resources :notifications, only: %i[index show]
    end

    resource :locale, only: :update

    resources :imports, only: %i[index create]
  end

  namespace :v1, module: "api/v1", as: "api_v1", defaults: { format: "json" } do
    resources :beneficiaries, only: [ :index, :create, :show, :update, :destroy ] do
      get "stats" => "beneficiaries/stats#index", on: :collection
      resources :addresses, only: [ :index, :create, :show, :destroy ]
    end

    resources :beneficiary_groups, only: [ :index, :show, :create, :update, :destroy ] do
      resources :members, controller: "beneficiary_groups/members", only: [ :index, :show, :create, :destroy ] do
        get "stats" => "beneficiary_groups/members/stats#index", on: :collection
      end
    end

    resources :broadcasts, only: [ :index, :show, :create, :update ] do
      resource :audio_file, controller: "broadcasts/audio_files", only: :show
      resources :notifications, controller: "broadcasts/notifications", only: [ :index, :show ] do
        get "stats" => "broadcasts/notifications/stats#index", on: :collection
      end
    end

    resources :events, only: [ :index, :show ] do
      get "stats" => "events/stats#index", on: :collection
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
