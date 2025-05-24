module Dashboard
  module Settings
    class UsersController < Dashboard::BaseController
      private

      def association_chain
        current_account.users
      end

      def show_location(resource)
        dashboard_settings_user_path(resource)
      end
    end
  end
end
