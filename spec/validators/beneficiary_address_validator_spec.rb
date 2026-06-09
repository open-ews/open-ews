require "rails_helper"

RSpec.describe BeneficiaryAddressValidator do
  it "validates a beneficiary address" do
    validator = BeneficiaryAddressValidator.new

    expect(
      validator.valid?(
        iso_region_code: "KH-1",
        administrative_division_level_2_code: nil,
        administrative_division_level_2_name: nil,
        administrative_division_level_3_code: nil,
        administrative_division_level_3_name: nil,
        administrative_division_level_4_code: nil,
        administrative_division_level_4_name: nil,
        administrative_division_level_5_code: nil,
        administrative_division_level_5_name: nil
      )
    ).to be(true)

    expect(
      validator.valid?(
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "0101",
        administrative_division_level_2_name: "Banteay Meanchey",
        administrative_division_level_3_code: "010101",
        administrative_division_level_3_name: "Mongkol Borei",
        administrative_division_level_4_code: "01020101",
        administrative_division_level_4_name: "Ou Thum",
        administrative_division_level_5_code: nil,
        administrative_division_level_5_name: nil
      )
    ).to be(true)

    expect(
      validator.valid?(
        iso_region_code: "KH-1",
        administrative_division_level_2_code: nil,
        administrative_division_level_2_name: nil,
        administrative_division_level_3_code: nil,
        administrative_division_level_3_name: nil,
        administrative_division_level_4_code: nil,
        administrative_division_level_4_name: nil,
        administrative_division_level_5_code: "0102010101",
        administrative_division_level_5_name: "Krom 1"
      )
    ).to be(false)
  end
end
