module SomlengWebhooks
  class CallStatusCallbacksController < SomlengWebhooksController
    def create
      ExecuteWorkflowJob.perform_later(HandleCallStatusCallback.to_s, params.fetch(:delivery_attempt_id), params: request.request_parameters)
      head(:no_content)
    end
  end
end
