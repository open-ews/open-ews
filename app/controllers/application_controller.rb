class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  respond_to :html

  protect_from_forgery with: :exception
end
