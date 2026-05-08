require "rails_helper"

RSpec.describe AccountPolicy do
  it "allows owners to manage account settings" do
    user = build_stubbed(:user, role: :owner)

    policy = described_class.new(user, user.account)

    expect(policy.show?).to be(true)
    expect(policy.update?).to be(true)
  end

  it "disallows members from managing account settings" do
    user = build_stubbed(:user, :member)

    policy = described_class.new(user, user.account)

    expect(policy.show?).to be(false)
    expect(policy.update?).to be(false)
  end
end
