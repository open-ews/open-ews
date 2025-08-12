class HandleStatusCallback < ApplicationWorkflow
  attr_reader :delivery_attempt, :resource

  def initialize(**options)
    super()
    @delivery_attempt = options.fetch(:delivery_attempt) { DeliveryAttempt.find(options.fetch(:delivery_attempt_id)) }
    @resource = options.fetch(:resource) do
      options.fetch(:parser).constantize.new.parse(options.fetch(:params))
    end
  end

  def call
    UpdateDeliveryAttempt.call(delivery_attempt, somleng_resource: resource)
    HandleDeliveryAttemptStatusUpdate.call(
      delivery_attempt,
      status: DeliveryAttemptStatusUpdate.new(
        channel: delivery_attempt.broadcast.channel,
        status: resource.status
      ).desired_status
    )
  end
end
