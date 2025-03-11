module Dashboard
  module Settings
    class AccountController < Dashboard::BaseController
      def show
        @resource = current_account
      end
    end
  end
end
