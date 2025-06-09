module Dashboard
  module Settings
    class AccountsController < DashboardController
      def show
        @account = current_account
      end

      def update
        @account = current_account
        if @account.update(permitted_params)
          respond_with(@account, location: dashboard_settings_account_path)
        else
          render :show
        end
      end

      private

      def permitted_params
        params.require(:account).permit(
          :name,
          :iso_country_code,
          :logo,
          :somleng_account_sid,
          :somleng_auth_token,
          :notification_phone_number
        )
      end
    end
  end
end
