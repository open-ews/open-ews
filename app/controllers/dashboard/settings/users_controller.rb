module Dashboard
  module Settings
    class UsersController < DashboardController
      def index
        @users = paginate_resources(scope)
      end

      def show
        @user = scope.find(params[:id])
      end

      def new
        @user = UserForm.new
      end

      def create
        @user = UserForm.new(account: current_account, inviter: current_user, **permitted_params)
        @user.save
        respond_with(@user, location: -> {  dashboard_settings_user_path(@user) })
      end

      private

      def scope
        current_account.users
      end

      def permitted_params
        params.require(:user).permit(:name, :email)
      end

      def flash_interpolation_options
        { email: @user.email }
      end
    end
  end
end
