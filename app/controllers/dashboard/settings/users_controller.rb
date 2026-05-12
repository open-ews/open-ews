module Dashboard
  module Settings
    class UsersController < DashboardController
      def index
        authorize(User)
        @users = paginate_resources(scope)
      end

      def show
        @user = find_user
      end

      def new
        @user = UserForm.new
        authorize(@user)
      end

      def create
        @user = UserForm.new(account: current_account, inviter: current_user, **permitted_params)
        authorize(@user)
        @user.save
        respond_with(@user, location: -> { dashboard_settings_user_path(@user) })
      end

      def destroy
        @user = find_user
        @user.destroy
        respond_with(@user, location: dashboard_settings_users_path)
      end

      private

      def find_user
        user = scope.find(params[:id])
        authorize(user)
        user
      end

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
