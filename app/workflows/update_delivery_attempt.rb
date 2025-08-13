class UpdateDeliveryAttempt < ApplicationWorkflow
  attr_reader :delivery_attempt, :somleng_resource

  def initialize(delivery_attempt, somleng_resource:)
    super()
    @delivery_attempt = delivery_attempt
    @somleng_resource = somleng_resource
  end

  def call
    delivery_attempt.metadata["call_duration"] = somleng_resource.call_duration if somleng_resource.call_duration.present?
    delivery_attempt.metadata["somleng_status"] = somleng_resource.status
    delivery_attempt.save!
  end
end
