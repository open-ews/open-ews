module Dashboard
  class BroadcastsController < Dashboard::BaseController
    helper_method :broadcast_summary

    def new
      super

      @resource = BroadcastForm.new
    end

    def edit
      super

      broadcast = @resource
      @resource = BroadcastForm.initialize_with(
        broadcast,
        beneficiary_filter: broadcast.beneficiary_filter
      )
    end

    private

    def prepare_resource_for_create
      broadcast = @resource
      @resource =  BroadcastForm.new(
        object: broadcast,
        **permitted_params
      )
    end

    def prepare_resource_for_update
      broadcast = @resource
      @resource =  BroadcastForm.new(
        object: broadcast,
        **permitted_params
      )
    end

    def association_chain
      current_account.broadcasts
    end

    def permitted_params
      permitted = params.fetch(:broadcast, {}).permit(:audio_file, :channel)

      if params.dig(:broadcast, :beneficiary_filter).present?
        permitted[:beneficiary_filter] = BroadcastForm::BeneficiaryFilter.new(
          params.dig(:broadcast, :beneficiary_filter).permit!
        )
      end

      permitted
    end

    def broadcast_summary
      @broadcast_summary ||= BroadcastSummary.new(resource)
    end
  end
end
