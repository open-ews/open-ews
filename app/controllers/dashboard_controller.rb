class DashboardController < ApplicationController
  self.responder = ApplicationResponder

  include DashboardTheme
  include UserAuthorization

  layout "dashboard"

  prepend_before_action :authenticate_user!
  before_action :enforce_two_factor_authentication!
  before_action :set_locale

  private

  def paginate_resources(resources_scope)
    resources_scope.latest_first.page(params[:page]).without_count
  end

  def set_locale
    I18n.locale = current_user.language
  end

  def filter_param
    params.fetch(:filter, {}).permit!
  end

  def enforce_two_factor_authentication!
    return if current_user.otp_required_for_login?

    redirect_to(
      new_dashboard_two_factor_authentication_path,
      alert: "Two Factor Authentication Required",
      status: :see_other
    )
  end
end
