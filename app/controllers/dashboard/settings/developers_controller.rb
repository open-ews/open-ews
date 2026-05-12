module Dashboard
  module Settings
    class DevelopersController < DashboardController
      def show
        authorize(current_account, :manage?)
      end
    end
  end
end
