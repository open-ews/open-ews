module Dashboard
  class NotificationsController < DashboardController
    def index
      @notifications = paginate_resources(scope)
    end

    def show
      @notification = scope.find(params[:id])
    end

    private

    def scope
      broadcast.notifications
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(params[:broadcast_id])
    end
  end
end
