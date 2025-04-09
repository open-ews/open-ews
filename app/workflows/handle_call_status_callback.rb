class HandleCallStatusCallback < ApplicationWorkflow
  attr_reader :delivery_attempt, :call_status_callback

  def initialize(**options)
    @delivery_attempt = options.fetch(:delivery_attempt) { DeliveryAttempt.find(options.fetch(:delivery_attempt_id)) }
    @call_status_callback = options.fetch(:call_status_callback) do
      Somleng::Parser::CallStatusCallbackParser.new.parse(options.fetch(:params))
    end
 end

  def call
    delivery_attempt.transaction do
      HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: call_status_callback.call_status)
      delivery_attempt.metadata["somleng_status"] = call_status_callback.call_status
      delivery_attempt.metadata["call_duration"] = call_status_callback.call_duration
      delivery_attempt.save!
    end
  end
end
