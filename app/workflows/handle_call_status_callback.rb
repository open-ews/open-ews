class HandleCallStatusCallback < ApplicationWorkflow
  attr_reader :delivery_attempt, :call_status_callback

  def initialize(delivery_attempt_id, options = {})
    @delivery_attempt = DeliveryAttempt.find(delivery_attempt_id)
    @call_status_callback = options.fetch(:call_status_callback) do
      Somleng::Parser::CallStatusCallbackParser.new.parse(options.fetch(:params))
    end
 end

  def call
    UpdateDeliveryAttemptStatus.call(delivery_attempt, status: call_status_callback.call_status)
  end
end
