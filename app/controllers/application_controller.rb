class ApplicationController < ActionController::Base
  allow_browser versions: :modern, block: :handle_outdated_browser
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

  def handle_outdated_browser
    render "errors/show", status: 406, locals: { status_code: 406 }
  end
end
