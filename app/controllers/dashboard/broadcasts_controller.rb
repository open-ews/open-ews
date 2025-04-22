module Dashboard
  class BroadcastsController < Dashboard::BaseController
    helper_method :broadcast_summary

    def edit
      super

      @resource.beneficiary_filter = @resource.beneficiary_filter.each_with_object({}) do |(field, options), result|
        result[field] = {
          operator: options.first.first,
          value: options.first.last
        }
      end
    end

    private

    def association_chain
      current_account.broadcasts
    end

    def permitted_params
      permitted = params.fetch(:broadcast, {}).permit(:audio_file, :channel)

      if params.dig(:broadcast, :beneficiary_filter).present?
        permitted[:beneficiary_filter] = BeneficiaryFilterFormRequestSchema.new(
          input_params: params.dig(:broadcast, :beneficiary_filter).permit!
        ).output
      end

      permitted
    end

    def before_update_attributes
      clear_metadata
      resource.settings.clear
    end

    def build_key_value_fields
      build_metadata_field
      resource.build_settings_field if resource.settings_fields.empty?
    end

    def prepare_resource_for_create
      resource.created_by ||= current_user
    end

    def prepare_resource_for_edit
      unless resource.not_yet_started?
        redirect_to(
          dashboard_broadcast_path(resource),
          alert: I18n.t("flash.broadcasts.not_allowed_to_edit")
        )
      end

      super
    end

    def broadcast_summary
      @broadcast_summary ||= BroadcastSummary.new(resource)
    end
  end
end
