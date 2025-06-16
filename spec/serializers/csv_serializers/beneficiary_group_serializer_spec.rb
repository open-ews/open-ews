require "rails_helper"

module CSVSerializers
  RSpec.describe BeneficiaryGroupSerializer do
    it "serializes the beneficiary group" do
      account = create(:account)
      group = create(:beneficiary_group, name: "Group 1", account: account)
      create(:beneficiary, phone_number: "+85510888123", account: account, groups: [ group ])
      create(:beneficiary, phone_number: "+85510888456", account: account, groups: [ group ])

      serializer = BeneficiaryGroupSerializer.new(group)

      expect(serializer.headers).to eq([
        "id",
        "created_at",
        "updated_at",
        "name",
        "members"
      ])

      row = serializer.as_csv
      expect(row).to eq([
        group.id,
        group.created_at.iso8601,
        group.updated_at.iso8601,
        "Group 1",
        "85510888123, 85510888456"
      ])
    end
  end
end
