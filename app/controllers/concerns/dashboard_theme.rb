module DashboardTheme
  extend ActiveSupport::Concern

  included do
    before_action :set_theme
  end

  private

  def set_theme
    cookies[:theme] = params.fetch(:theme) { cookies.fetch(:theme, "light") }
  end
end
