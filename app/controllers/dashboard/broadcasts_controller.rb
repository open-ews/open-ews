module Dashboard
  class BroadcastsController < Dashboard::BaseController
    helper_method :broadcast_summary

    private

    def association_chain
      current_account.broadcasts
    end

    def permitted_params
      params.fetch(:broadcast).permit(:audio_file, :audio_url, :channel)
    end

    def broadcast_summary
      @broadcast_summary ||= BroadcastSummary.new(resource)
    end
  end
end
