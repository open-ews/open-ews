module API
  module V1
    module Broadcasts
      class NotificationsController < API::V1::BaseController
        def index
          apply_filters(notifications_scope, with: NotificationFilter)
        end

        def show
          notification = notifications_scope.find(params[:id])
          respond_with_resource(notification)
        end

        private

        def broadcast
          @broadcast ||= current_account.broadcasts.find(params[:broadcast_id])
        end

        def notifications_scope
          broadcast.notifications
        end
      end
    end
  end
end
