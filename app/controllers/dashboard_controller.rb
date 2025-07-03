class DashboardController < ApplicationController
  self.responder = ApplicationResponder

  include DashboardTheme

  layout "dashboard"

  before_action :authenticate_user!, :set_locale
  before_action :authorize_account!

  helper_method :current_account

  private

  def authorize_account!
    return if current_account == current_user.account

    sign_out(current_user)
    redirect_to(
      new_user_session_url(host: current_account.subdomain_host),
      status: :see_other,
      alert: t("devise.failure.invalid", authentication_keys: :email)
    )
  end

  def paginate_resources(resources_scope)
    resources_scope.latest_first.page(params[:page]).without_count
  end

  def set_locale
    I18n.locale = current_user.language
  end

  def filter_param
    params.fetch(:filter, {}).permit!
  end
end
