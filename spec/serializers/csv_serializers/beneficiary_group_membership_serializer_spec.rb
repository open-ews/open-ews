require "rails_helper"

module CSVSerializers
  RSpec.describe BeneficiaryGroupMembershipSerializer do
    it "serializes the beneficiary group membership attributes" do
      account = create(:account)
      beneficiary = create(:beneficiary, phone_number: "85510555123", account:)
      beneficiary_group = create(:beneficiary_group, account:)
      membership = create(:beneficiary_group_membership, beneficiary:, beneficiary_group:)

      result = BeneficiaryGroupMembershipSerializer.new(membership).as_json

      expect(result[:beneficiary_id]).to eq(beneficiary.id)
      expect(result[:phone_number]).to eq("85510555123")
      expect(result[:created_at]).to eq(membership.created_at.iso8601)
    end
  end
end
