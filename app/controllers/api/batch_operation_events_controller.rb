module API
  class BatchOperationEventsController < API::BaseController
    def create
      @resource = LegacyEvent::BatchOperation.new(eventable: batch_operation, **permitted_params)
      if @resource.save
        respond_with(batch_operation, location: -> { api_batch_operation_path(batch_operation) })
      else
        respond_with(@resource)
      end
    end

    private

    def scope
      current_account.batch_operations
    end

    def batch_operation
      @batch_operation ||= scope.find(params[:batch_operation_id])
    end

    def permitted_params
      params.permit(:event)
    end
  end
end
