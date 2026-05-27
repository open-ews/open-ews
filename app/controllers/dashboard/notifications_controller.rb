module Dashboard
  class NotificationsController < DashboardController
    def index
      authorize(Notification)
      @filter_form = NotificationFilterForm.new(filter_param)
      @notifications = paginate_resources(@filter_form.apply(scope))
    end

    def show
      @notification = scope.find(params[:id])
      authorize(@notification)
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
