class Users::InvitationsController < Devise::InvitationsController
  include DashboardTheme

  helper_method :current_account
  layout :resolve_layout

  before_action :set_locale

  protected

  def current_account
    current_user.account if user_signed_in?
  end

  def invite_params
    super.merge(permitted_params).merge(account_id: current_inviter.account_id)
  end

  def permitted_params
    params.require(:user).permit(:email, :name)
  end

  def after_invite_path_for(_inviter, _invitee = nil)
    dashboard_settings_users_path
  end

  def resolve_layout
    user_signed_in? ? "dashboard" : "devise"
  end

  def set_locale
    I18n.locale = current_user.locale if user_signed_in?
  end
end
