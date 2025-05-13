require "rails_helper"

RSpec.describe CreateBeneficiary do
  it "creates a beneficiary" do
    account = create(:account)

    beneficiary = CreateBeneficiary.call(
      account:,
      phone_number: "+85510999999",
      iso_country_code: "KH",
    )

    expect(beneficiary).to have_attributes(
      phone_number: "85510999999",
      iso_country_code: "KH"
    )
    expect(account.events).to contain_exactly(
      have_attributes(
        type: "beneficiary.created",
        details: {
          "data" => {
            "id" => beneficiary.id.to_s,
            "type" => "beneficiary"
          }
        }
      )
    )
  end

  it "creates a beneficiary with an address" do
    account = create(:account)

    beneficiary = CreateBeneficiary.call(
      account:,
      phone_number: "+85510999999",
      iso_language_code: "km",
      gender: "M",
      date_of_birth: "1990-01-01",
      metadata: { "foo" => "bar" },
      iso_country_code: "KH",
      address: {
        iso_region_code: "KH-1",
        administrative_division_level_2_code: "0112"
      }
    )

    expect(beneficiary).to have_attributes(
      phone_number: "85510999999",
      iso_language_code: "km",
      gender: "M",
      date_of_birth: Date.parse("1990-01-01"),
      metadata: { "foo" => "bar" },
      iso_country_code: "KH"
    )
    expect(beneficiary.addresses.first).to have_attributes(
      iso_region_code: "KH-1",
      administrative_division_level_2_code: "0112"
    )
  end

  it "creates a beneficiary and adds it to a group" do
    account = create(:account)
    beneficiary_group = create(:beneficiary_group, account:)

    beneficiary = CreateBeneficiary.call(
      account:,
      phone_number: "+85510999999",
      iso_country_code: "KH",
      group_ids: [ beneficiary_group.id ]
    )

    expect(beneficiary).to have_attributes(
      groups: contain_exactly(beneficiary_group)
    )
  end
end
