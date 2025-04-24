module Dashboard
  class BroadcastsController < Dashboard::BaseController
    helper_method :broadcast_summary

    # before_action :not_allowed_to_edit, only: [ :edit, :update ]

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


    # TODO: verify if the user can edit broadcast
    # def not_allowed_to_edit
    #   return if resource.not_yet_started?
    #
    #   redirect_to(
    #     dashboard_broadcast_path(resource),
    #     alert: I18n.t("flash.broadcasts.not_allowed_to_edit")
    #   )
    # end

    def broadcast_summary
      @broadcast_summary ||= BroadcastSummary.new(resource)
    end
  end
end
