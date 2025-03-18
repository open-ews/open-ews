class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  helper_method :current_account
  layout :resolve_layout

  private

  def update_resource(resource, params)
    return super if params.key(:email) || params.key?(:password)

    # NOTE: Update user's profile only
    resource.update_without_password(params)
  end

  def resolve_layout
    user_signed_in? ? "dashboard" : "devise"
  end

  def current_account
    current_user&.account
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
