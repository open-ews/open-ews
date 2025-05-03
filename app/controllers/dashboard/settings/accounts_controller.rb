module Dashboard
  module Settings
    class AccountsController < Dashboard::BaseController
      private

      def find_resource
        @resource = current_account
      end

      def permitted_params
        params.require(:account).permit(
          :name,
          :somleng_account_sid,
          :somleng_auth_token,
        )
      end

      def show_location(_resource)
        dashboard_settings_account_path
      end
    end
  end
end
