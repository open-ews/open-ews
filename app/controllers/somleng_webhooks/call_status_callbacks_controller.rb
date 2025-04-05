module SomlengWebhooks
  class CallStatusCallbacksController < SomlengWebhooksController
    def create
      ExecuteWorkflowJob.perform_later(
        HandleCallStatusCallback.to_s,
        delivery_attempt_id: params.fetch(:delivery_attempt_id),
        params: request.request_parameters
      )
      head(:no_content)
    end
  end
end
