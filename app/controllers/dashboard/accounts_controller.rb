module Dashboard
  class AccountsController < Dashboard::BaseController
    private

    def find_resource
      @resource = current_account
    end

    def permitted_params
      params.require(:account).permit(
        :somleng_account_sid,
        :somleng_auth_token
      )
    end

    def show_location(_resource)
      edit_dashboard_account_path
    end
  end
end
