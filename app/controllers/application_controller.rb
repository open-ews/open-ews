class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # FIXME: Failed validations right now didn't show up
  # respond_to :html, :turbo_stream
  respond_to :html

  protect_from_forgery with: :exception
end
