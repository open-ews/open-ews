class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  helper_method :current_account
  layout :resolve_layout

  def current_account
    current_user.account if user_signed_in?
  end

  private

  def resolve_layout
    user_signed_in? ? "dashboard" : "devise"
  end

  def update_resource(resource, params)
    return super if params.key(:email) || params.key?(:password)

    # NOTE: Update user's profile only
    resource.update_without_password(params)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def after_update_path_for(_resource)
    user_signed_in? ? edit_user_registration_path : new_user_session_path
  end
end
