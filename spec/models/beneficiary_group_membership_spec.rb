require "rails_helper"

RSpec.describe BeneficiaryGroupMembership do
  it "validates the beneficiary and group belong to the same account" do
    beneficiary_group = create(:beneficiary_group)
    beneficiary = create(:beneficiary)
    group = build(:beneficiary_group_membership, beneficiary_group:, beneficiary:)

    group.valid?

    expect(group.errors[:beneficiary_group]).to be_present
  end
end
