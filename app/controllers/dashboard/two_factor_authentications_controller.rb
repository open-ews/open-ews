module Dashboard
  class TwoFactorAuthenticationsController < DashboardController
    skip_before_action :enforce_two_factor_authentication!, only: %i[new create]

    def new
      authorize(current_user, policy_class: TwoFactorAuthenticationPolicy)
      @resource = TwoFactorAuthenticationForm.new
    end

    def create
      authorize(current_user, policy_class: TwoFactorAuthenticationPolicy)
      @resource = TwoFactorAuthenticationForm.new(permitted_params)
      @resource.user = current_user
      @resource.save

      respond_with(
        @resource,
        notice: "2FA was successfully enabled.",
        location: -> { after_sign_in_path_for(current_user) }
      )
    end

    def destroy
      user = current_account.users.find(params[:id])
      authorize(user, policy_class: TwoFactorAuthenticationPolicy)
      user.update!(otp_required_for_login: false)

      flash[:notice] = t("flash.dashboard.two_factor_authentications.destroy.notice", email: user.email)
      redirect_back_or_to(dashboard_root_path)
    end

    private

    def permitted_params
      params.require(:two_factor_authentication).permit(:otp_attempt)
    end
  end
end
