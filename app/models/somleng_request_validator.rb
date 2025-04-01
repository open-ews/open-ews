class SomlengRequestValidator
  class InvalidSignatureError < StandardError; end

  def validate_request(auth_token:, url:, params:, signature:)
    raise InvalidSignatureError.new("Invalid signature: #{signature}") unless request_validator_for(auth_token).validate(url, params, signature)
  end

  def build_signature_for(auth_token:, url:, params:)
    request_validator_for(auth_token).build_signature_for(url, params)
  end

  private

  def request_validator_for(auth_token)
    Twilio::Security::RequestValidator.new(auth_token)
  end
end
