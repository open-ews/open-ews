class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  respond_to :html

  protect_from_forgery with: :exception

  helper_method :current_account
  helper_method :app_request

  private

  def current_account
    @current_account ||= app_request.find_account!
  end

  def app_request
    AppRequest.new(request)
  end
end
