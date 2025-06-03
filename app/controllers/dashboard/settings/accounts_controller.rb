module Dashboard
  module Settings
    class AccountsController < DashboardController
      def update
        current_account.update(permitted_params)
        respond_with(current_account, location: dashboard_settings_account_path)
      end

      private

      def permitted_params
        params.require(:account).permit(
          :name,
          :iso_country_code,
          :somleng_account_sid,
          :somleng_auth_token,
          :notification_phone_number,
        )
      end
    end
  end
end
