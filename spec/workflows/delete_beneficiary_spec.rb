require "rails_helper"

RSpec.describe DeleteBeneficiary do
  it "deletes a beneficiary" do
    account = create(:account)
    beneficiary = create(:beneficiary, account:)

    DeleteBeneficiary.call(beneficiary)

    expect(account.events).to contain_exactly(
      have_attributes(
        type: "beneficiary.deleted"
      )
    )
    expect(account.beneficiaries.find_by(id: beneficiary.id)).to be_nil
  end
end
