class DashboardController < ApplicationController
  self.responder = ApplicationResponder

  include DashboardTheme

  layout "dashboard"

  before_action :authenticate_user!, :set_locale

  helper_method :current_account

  private

  def paginate_resources(resources_scope)
    resources_scope.latest_first.page(params[:page]).without_count
  end

  def set_locale
    I18n.locale = current_user.locale
  end

  def current_account
    current_user.account
  end

  def filter_param
    params.fetch(:filter, {}).permit!
  end
end
