class SomlengWebhooksController < ApplicationController
  skip_forgery_protection

  before_action :verify_signature

  rescue_from Somleng::RequestValidator::InvalidSignatureError, with: :invalid_signature

  private

  def verify_signature
    request_validator.validate_request(
      auth_token:,
      url: request.url,
      params: request.request_parameters,
      signature: request.headers["X-Twilio-Signature"]
    )
  end

  def account_sid
    request.request_parameters[:AccountSid]
  end

  def auth_token
    Account.find_by!(somleng_account_sid: account_sid).somleng_auth_token
  end

  def request_validator
    @request_validator ||= Somleng::RequestValidator.new
  end

  def invalid_signature
    head :forbidden
  end
end
