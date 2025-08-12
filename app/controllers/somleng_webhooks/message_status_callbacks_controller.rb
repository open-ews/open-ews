module SomlengWebhooks
  class MessageStatusCallbacksController < SomlengWebhooksController
    def create
      ExecuteWorkflowJob.perform_later(
        HandleStatusCallback.to_s,
        delivery_attempt_id: params.fetch(:delivery_attempt_id),
        params: request.request_parameters,
        parser: Somleng::Parser::MessageStatusCallbackParser.to_s
      )
      head(:no_content)
    end
  end
end
