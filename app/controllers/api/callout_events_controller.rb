module API
  class CalloutEventsController < API::BaseController
    def create
      @resource = LegacyEvent::Callout.new(eventable: broadcast, **permitted_params)
      if @resource.save
        respond_with(broadcast, location: -> { api_callout_path(broadcast) })
      else
        respond_with(@resource)
      end
    end

    private

    def scope
      current_account.broadcasts
    end

    def permitted_params
      params.permit(:event)
    end

    def broadcast
      @broadcast ||= scope.find(params[:callout_id])
    end
  end
end
