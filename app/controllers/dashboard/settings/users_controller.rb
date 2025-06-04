module Dashboard
  module Settings
    class UsersController < DashboardController
      def index
        @users = paginate_resources(scope)
      end

      def show
        @user = scope.find(params[:id])
      end

      private

      def scope
        current_account.users
      end
    end
  end
end
