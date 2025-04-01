class SomlengWebhooksController < ApplicationController
  skip_forgery_protection

  before :verify_signature

  private

  def verify_signature
    request_validator.validate_request(
      auth_token:,
      url: request.url,
      params: request.query_parameters,
      signature: request.headers["X-Twilio-Signature"]
    )
  end

  def auth_token
    Account.find_by!(somleng_account_sid: request.request_parameters[:AccountSid]).somleng_auth_token
  end

  def request_validator
    @request_validator ||= SomlengRequestValidator.new
  end
end
