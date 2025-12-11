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
    root to: "home#index", as: :authenticated_root
  end

  # ログインしていないユーザーのルート
  unauthenticated do
    devise_scope :user do
      root to: "devise/sessions#new"
    end
  end
end
