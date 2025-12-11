class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Deviseのストロングパラメータ設定
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Deviseコントローラーでloginレイアウトを使用
  layout :layout_by_resource

  private

  def layout_by_resource
    if devise_controller?
      "login"
    else
      "application"
    end
  end

  def configure_permitted_parameters
    # サインアップ時にnameパラメータを許可
    # deviseのデフォルトでは :email と :password :password_confirmation しか許可されないため
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    # アカウント更新時にもnameパラメータを許可
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
