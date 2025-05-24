module DarkMode
  extend ActiveSupport::Concern

  included do
    before_action :set_theme
  end

  private

  def set_theme
    cookies[:theme] = params.fetch(:theme) { cookies[:theme] || "light" }
  end
end
