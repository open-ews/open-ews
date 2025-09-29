class UpdateDeliveryAttempt < ApplicationWorkflow
  attr_reader :delivery_attempt, :somleng_resource

  SIP_RESPONSE_CODE_TO_ERROR_CODE_MAPPING = {
    "404" => "phone_number_unreachable"
  }.freeze

  def initialize(delivery_attempt, somleng_resource:)
    super()
    @delivery_attempt = delivery_attempt
    @somleng_resource = somleng_resource
  end

  def call
    update_metadata
    set_error_code
    delivery_attempt.save!
  end

  private

  def update_metadata
    delivery_attempt.metadata["call_duration"] = somleng_resource.call_duration if somleng_resource.call_duration.present?
    delivery_attempt.metadata["sip_response_code"] = somleng_resource.sip_response_code if somleng_resource.sip_response_code.present?
    delivery_attempt.metadata["somleng_status"] = somleng_resource.status
  end

  def set_error_code
    delivery_attempt.error_code = SIP_RESPONSE_CODE_TO_ERROR_CODE_MAPPING[somleng_resource.sip_response_code]
  end
end
