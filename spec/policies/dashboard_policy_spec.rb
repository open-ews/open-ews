require "rails_helper"

RSpec.describe BeneficiaryPolicy do
  it "allows members to manage resources under dashboard" do
    user = build_stubbed(:user, :member)
    resource = build_stubbed(:beneficiary, account: user.account)

    policy = described_class.new(user, resource)

    expect(policy.index?).to be(true)
    expect(policy.show?).to be(true)
    expect(policy.new?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.edit?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end
