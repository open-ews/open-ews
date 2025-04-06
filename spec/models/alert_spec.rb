require "rails_helper"

RSpec.describe Alert do
  it "sets defaults" do
    beneficiary = create(:beneficiary)
    alert = build(:alert, beneficiary: beneficiary)

    alert.save!

    expect(alert.phone_number).to eq(beneficiary.phone_number)
  end
end
