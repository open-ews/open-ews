module Dashboard
  class NotificationsController < Dashboard::BaseController
    private

    def association_chain
      broadcast.notifications
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(params[:broadcast_id])
    end

    def show_location(resource)
      dashboard_broadcast_notification_path(resource.broadcast, resource)
    end

    def filter_class
      Filter::Resource::Notification
    end
  end
end
