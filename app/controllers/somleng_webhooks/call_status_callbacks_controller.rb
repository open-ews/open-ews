module SomlengWebhooks
  class CallStatusCallbacksController < SomlengWebhooksController
    def create
      delivery_attempt = DeliveryAttempt.find(params[:delivery_attempt_id])
      schema = CallStatusCallbackRequestSchema.new(input_params: request.request_parameters)
      result = HandleCallStatusCallback.call(delivery_attempt, schema.output)
      head(:no_content)
    end
  end
end
