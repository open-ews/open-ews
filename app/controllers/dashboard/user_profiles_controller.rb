module Dashboard
  class UserProfilesController < DashboardController
    def show
      @user = current_user
    end

    def update
      @user = current_user
      if @user.update(permitted_params)
        respond_with(@user, location: dashboard_user_profile_path)
      else
        render :show
      end
    end

    private

    def permitted_params
      params.require(:user).permit(:name)
    end
  end
end
