Rails.application.routes.draw do
  # テーブルと同じ複数形のリソース名を使う
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # ログイン後のホーム画面
  get "home/index"

  # ログイン済みユーザーのルート
  authenticated :user do
    root to: "coffee_beans#index", as: :authenticated_root
  end

  # ログインしていないユーザーのルート
  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new"
    end
  end

  # コーヒー豆管理機能のルーティング
  resources :coffee_beans, only: [ :index, :show, :new, :create, :edit, :update, :destroy ]

  # テイスティングノート管理機能のルーティング
  resources :tasting_notes, only: [ :index, :show ]
  resources :coffee_beans do
    # 新規作成時はどの豆の評価かが分かるようにネストさせる
    resources :tasting_notes, except: [ :index, :show ]
  end

  # AI分析機能のルーティング
  resources :chat_threads, only: [ :index, :show, :destroy ] do
    member do
      get :stream
    end
  end
  resources :chat_messages, only: [ :create ], controller: "chat_messages"
end
