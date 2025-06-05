class Users::RegistrationsController < Devise::RegistrationsController
  layout "dashboard"

  before_action :set_locale
  helper_method :current_account

  protected

  def current_account
    current_user.account
  end

  def after_update_path_for(_resource)
    edit_user_registration_path
  end

  def set_locale
    I18n.locale = current_user.locale
  end
end
