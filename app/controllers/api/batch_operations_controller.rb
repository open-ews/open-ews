module API
  class BatchOperationsController < API::BaseController
    def create
      @batch_operation = scope.where(broadcast_id: params[:callout_id]).new(permitted_params)
      if @batch_operation.broadcast&.pending?
        @batch_operation.save
      else
        @batch_operation.errors.add(:broadcast, "is not initialized")
      end

      respond_with(:api, @batch_operation, location: -> { api_batch_operation_path(@batch_operation) })
    end

    private

    def scope
      current_account.batch_operations
    end

    def permitted_params
      params.permit(:metadata_merge_mode, metadata: {}, parameters: {})
    end
  end
end
