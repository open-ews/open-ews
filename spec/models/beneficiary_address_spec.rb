require "rails_helper"

RSpec.describe BeneficiaryAddress do
  it "validates the address" do
    expect(
      build(
        :beneficiary_address,
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "0101",
        administrative_division_level_3_code: "010101"
      )
    ).to be_valid

    expect(
      build(
        :beneficiary_address,
        iso_region_code: "KH-1",
        administrative_division_level_3_code: "010101"
      )
    ).to be_invalid
  end
end
