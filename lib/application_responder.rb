class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder

  self.error_status = :unprocessable_content
  self.redirect_status = :see_other
end
