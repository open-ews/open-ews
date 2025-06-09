require "rails_helper"

RSpec.describe BroadcastBeneficiaryGroup do
  it "validates the broadcast and beneficiary group belong to the same account" do
    broadcast = create(:broadcast)
    beneficiary_group = create(:beneficiary_group)
    broadcast_beneficiary_group = build(:broadcast_beneficiary_group, broadcast:, beneficiary_group:)

    broadcast_beneficiary_group.valid?

    expect(broadcast_beneficiary_group.errors[:beneficiary_group]).to be_present
  end
end
