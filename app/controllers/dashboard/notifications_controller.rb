module Dashboard
  class NotificationsController < Dashboard::BaseController
    private

    def association_chain
      if parent_resource
        parent_resource.notifications
      else
        current_account.notifications
      end
    end

    def parent_resource
      broadcast
    end

    def broadcast_id
      params[:broadcast_id]
    end

    def broadcast
      @broadcast ||= current_account.broadcasts.find(broadcast_id)
    end

    def callout_population_id
      params[:batch_operation_id]
    end

    def callout_population
      @callout_population ||= current_account.batch_operations.find(callout_population_id)
    end

    def beneficiary_id
      params[:beneficiary_id]
    end

    def beneficiary
      @beneficiary ||= current_account.beneficiaries.find(beneficiary_id)
    end

    def show_location(resource)
      dashboard_broadcast_notification_path(resource.broadcast, resource)
    end

    def filter_class
      Filter::Resource::Notification
    end
  end
end
