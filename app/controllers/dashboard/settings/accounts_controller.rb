module Dashboard
  module Settings
    class AccountsController < DashboardController
      self.raise_on_open_redirects = false

      def show
        @account = current_account
      end

      def update
        @account = current_account
        if @account.update(permitted_params)
          respond_with(@account, location: dashboard_settings_account_url(host: @account.subdomain_host))
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
          :notification_phone_number,
          :subdomain
        )
      end
    end
  end
end
