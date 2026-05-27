class TwoFactorAuthenticationPolicy < ApplicationPolicy
  def create?
    !user.otp_required_for_login?
  end

  def destroy?
    account_owner?
  end
end
