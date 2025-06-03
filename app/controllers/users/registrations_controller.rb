class Users::RegistrationsController < Devise::RegistrationsController
  layout "dashboard"

  before_action :configure_permitted_parameters
  before_action :set_locale

  helper_method :current_account

  protected

  def current_account
    current_user.account
  end

  def update_resource(resource, params)
    return super if params.key?(:email) || params.key?(:password)

    # NOTE: Update user's profile only
    resource.update_without_password(params)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def after_update_path_for(_resource)
    edit_user_registration_path
  end

  def set_locale
    I18n.locale = current_user.locale
  end
end
