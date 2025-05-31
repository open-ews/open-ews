module Dashboard
  class LocalesController < DashboardController
    def update
      current_user.update!(permitted_params)
      redirect_back_or_to(dashboard_root_path)
    end

    def permitted_params
      params.require(:user).permit(:locale)
    end
  end
end
