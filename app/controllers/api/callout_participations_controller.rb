module API
  class CalloutParticipationsController < API::BaseController
    def index
      respond_with(:api, paginate(scope))
    end

    private

    def scope
      broadcast.notifications
    end

    def broadcast
      @broadcast = current_account.broadcasts.find(params[:callout_id])
    end
  end
end
