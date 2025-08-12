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
    delivery_attempt.metadata["call_duration"] = resource.call_duration if resource.call_duration.present?
    HandleDeliveryAttemptStatusUpdate.call(
      delivery_attempt,
      status_update: DeliveryAttemptStatusUpdate.new(
        channel: delivery_attempt.broadcast.channel,
        status: resource.status
      )
    )
  end
end
