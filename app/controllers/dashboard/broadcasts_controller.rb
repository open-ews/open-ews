module Dashboard
  class BroadcastsController < Dashboard::BaseController
    helper_method :broadcast_summary

    def new
      super

      @resource = BroadcastForm.new
    end

    def edit
      super

      @resource = BroadcastForm.initialize_with(@resource)
    end

    def show
      @broadcast = scope.find(params[:id])
    end

    def update
      broadcast = scope.find(params[:id])
      @resource = BroadcastForm.new(object: broadcast, **permitted_params)
      @resource.save
      respond_with(:dashboard, @resource)

      # UpdateBroadcast.call()
    rescue UpdateBroadcast::InvalidStateTransitionError
      redirect_to action: :show, error: "Invalid state transition"
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

    def scope
      current_account.broadcasts
    end

    def association_chain
      current_account.broadcasts
    end

    def permitted_params
      params.require(:broadcast).permit(:audio_file, :channel, :desired_status, beneficiary_filter: {})
    end

    def broadcast_summary
      @broadcast_summary ||= BroadcastSummary.new(resource)
    end
  end
end
