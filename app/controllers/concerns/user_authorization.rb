module UserAuthorization
  extend ActiveSupport::Concern

  include Pundit::Authorization
  include Devise::Controllers::SignInOut

  included do
    helper_method :current_account

    before_action :authorize_account!
    after_action :verify_authorized

    rescue_from Pundit::NotAuthorizedError do
      redirect_to(
        dashboard_root_path,
        alert: "You are not authorized to perform this action",
        status: :see_other
      )
    end
  end

  private

  def authorize_account!
    return if current_account == current_user.account

    sign_out(current_user)
    redirect_to(
      new_user_session_url(host: current_account.subdomain_host),
      status: :see_other,
      alert: t("devise.failure.invalid", authentication_keys: "email")
    )
  end
end
