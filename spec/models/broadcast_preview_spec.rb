require "rails_helper"

RSpec.describe BroadcastPreview do
  it "preview a broadcast" do
    account = create(:account)
    beneficiary = create(:beneficiary, account:, gender: "F")
    create(:beneficiary, :disabled, account:, gender: "F")
    beneficiary_in_group = create(:beneficiary, account:, gender: "M")
    beneficiary_group = create(:beneficiary_group, account:)
    create(:beneficiary, account:, gender: "M")
    create(:beneficiary_group_membership, beneficiary_group:, beneficiary: beneficiary_in_group)

    broadcast = create(
      :broadcast,
      status: :queued,
      account:,
      beneficiary_filter: {
        gender: { eq: "F" }
      },
      beneficiary_groups: [ beneficiary_group ]
    )

    preview = BroadcastPreview.new(broadcast)

    expect(preview.filtered_beneficiaries).to contain_exactly(beneficiary)
    expect(preview.group_beneficiaries).to contain_exactly(beneficiary_in_group)
    expect(preview.beneficiaries).to contain_exactly(beneficiary, beneficiary_in_group)
  end
end
