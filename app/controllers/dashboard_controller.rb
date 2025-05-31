class DashboardController < ApplicationController
  self.responder = ApplicationResponder

  include DashboardTheme

  layout "dashboard"

  before_action :authenticate_user!, :set_locale

  helper_method :current_account

  private

  def set_locale
    I18n.locale = current_user.locale
  end

  def current_account
    current_user.account
  end
end
