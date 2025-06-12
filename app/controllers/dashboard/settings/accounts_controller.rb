module Dashboard
  module Settings
    class AccountsController < DashboardController
      self.raise_on_open_redirects = false

      def show
        @account = AccountForm.initialize_with(current_account)
      end

      def update
        @account = AccountForm.new(object: current_account, **permitted_params)
        if @account.save
          respond_with(@account, location: dashboard_settings_account_url(host: @account.subdomain_host))
        else
          render :show
        end
      end

      private

      def permitted_params
        params.require(:account).permit(
          :name,
          :country,
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
