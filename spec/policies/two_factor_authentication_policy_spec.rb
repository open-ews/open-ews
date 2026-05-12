require "rails_helper"

RSpec.describe TwoFactorAuthenticationPolicy do
  it "allows all users to set up their own 2fa" do
    user = build_stubbed(:user, :member, otp_required_for_login: false)

    policy = TwoFactorAuthenticationPolicy.new(user, user)

    expect(policy.new?).to be(true)
    expect(policy.create?).to be(true)
  end

  it "only allows owners to reset another user's 2fa" do
    owner = build_stubbed(:user, role: :owner)
    member = build_stubbed(:user, :member)

    expect(TwoFactorAuthenticationPolicy.new(owner, member).destroy?).to be(true)
    expect(TwoFactorAuthenticationPolicy.new(member, owner).destroy?).to be(false)
  end
end
