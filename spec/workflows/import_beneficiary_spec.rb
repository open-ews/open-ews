require "rails_helper"

RSpec.describe ImportBeneficiary do
  it "imports a beneficiary" do
    import = create(:import, :beneficiaries)

    beneficiary = ImportBeneficiary.call(
      import:,
      data: {
        phone_number: "85516789111",
        iso_country_code: "KH"
      }
    )

    expect(beneficiary).to have_attributes(
      persisted?: true,
      phone_number: "85516789111",
      iso_country_code: "KH"
    )
  end

  it "handles optional attributes" do
    import = create(:import, :beneficiaries)

    beneficiary = ImportBeneficiary.call(
      import:,
      data: {
        phone_number: "85516789111",
        iso_country_code: "KH",
        disability_status: "disabled",
        date_of_birth: "1990-01-01",
        iso_language_code: "khm",
        gender: "M",
        meta_my_attribute: "my_value",
        "address_iso_region_code": "KH-1",
        "address_administrative_division_level_2_code": "0102",
        "address_administrative_division_level_2_name": "Mongkol Borei",
        "address_administrative_division_level_3_code": "010201",
        "address_administrative_division_level_3_name": "Banteay Neang",
        "address_administrative_division_level_4_code": "01020101",
        "address_administrative_division_level_4_name": "Ou Thum"
      }
    )

    expect(beneficiary).to have_attributes(
      persisted?: true,
      phone_number: "85516789111",
      iso_country_code: "KH",
      iso_language_code: "khm",
      disability_status: "disabled",
      date_of_birth: Date.new(1990, 1, 1),
      gender: "M",
      metadata: { "my_attribute" => "my_value" },
      addresses: contain_exactly(
        have_attributes(
          iso_region_code: "KH-1",
          administrative_division_level_2_code: "0102",
          administrative_division_level_2_name: "Mongkol Borei",
          administrative_division_level_3_code: "010201",
          administrative_division_level_3_name: "Banteay Neang",
          administrative_division_level_4_code: "01020101",
          administrative_division_level_4_name: "Ou Thum"
        )
      )
    )
  end

  it "handles updating beneficiaries" do
    import = create(:import)
    beneficiary = create(
      :beneficiary,
      phone_number: "85516789111",
      iso_country_code: "KH",
      iso_language_code: "khm",
      disability_status: "disabled",
      date_of_birth: Date.new(1990, 1, 1),
      gender: "M",
      account: import.account
    )

    ImportBeneficiary.call(
      import:,
      data: {
        phone_number: "+85516789111",
        iso_country_code: "KH",
        iso_language_code: "eng",
        disability_status: "normal",
        date_of_birth: Date.new(1991, 1, 1),
        gender: "F"
      }
    )

    expect(beneficiary.reload).to have_attributes(
      account: beneficiary.account,
      phone_number: "85516789111",
      iso_country_code: "KH",
      iso_language_code: "eng",
      disability_status: "normal",
      date_of_birth: Date.new(1991, 1, 1),
      gender: "F"
    )
  end

  it "handles creating an address for an existing beneficiary" do
    import = create(:import)
    beneficiary = create(
      :beneficiary,
      phone_number: "85516789111",
      iso_country_code: "KH",
      account: import.account
    )

    ImportBeneficiary.call(
      import:,
      data: {
        phone_number: "85516789111",
        iso_country_code: "KH",
        "address_iso_region_code": "KH-1",
        "address_administrative_division_level_2_code": "0102",
      }
    )

    expect(beneficiary).to have_attributes(
      addresses: contain_exactly(
        have_attributes(
          iso_region_code: "KH-1",
          administrative_division_level_2_code: "0102"
        )
      )
    )
  end

  it "handles updating an address for an existing beneficiary" do
    import = create(:import)
    beneficiary = create(
      :beneficiary,
      phone_number: "85516789111",
      iso_country_code: "KH",
      account: import.account
    )
    create(:beneficiary_address, beneficiary:, iso_region_code: "KH-1")

    ImportBeneficiary.call(
      import:,
      data: {
        phone_number: "85516789111",
        iso_country_code: "KH",
        "address_iso_region_code": "KH-12",
        "address_administrative_division_level_2_code": "1201",
      }
    )

    expect(beneficiary).to have_attributes(
      addresses: contain_exactly(
        have_attributes(
          iso_region_code: "KH-12",
          administrative_division_level_2_code: "1201"
        )
      )
    )
  end

  it "fails to update an address when there are multiple addresses for the beneficiary" do
    import = create(:import)
    beneficiary = create(
      :beneficiary,
      phone_number: "85516789111",
      iso_country_code: "KH",
      account: import.account
    )
    create(:beneficiary_address, beneficiary:, iso_region_code: "KH-1")
    create(:beneficiary_address, beneficiary:, iso_region_code: "KH-2")

    expect {
      ImportBeneficiary.call(
        import:,
        data: {
          phone_number: "85516789111",
          iso_country_code: "KH",
          "address_iso_region_code": "KH-12",
          "address_administrative_division_level_2_code": "1201",
        }
      )
    }.to raise_error(Errors::ImportError, "Beneficiary has multiple addresses")
  end

  it "handles invalid attributes" do
    import = create(:import)

    expect {
      ImportBeneficiary.call(import:, data: { phone_number: "1234" })
    }.to raise_error(Errors::ImportError)
  end

  it "fails to create a beneficiary with marked_for_deletion flag" do
    import = create(:import)

    expect {
      ImportBeneficiary.call(
        import:,
        data: {
          number: "85516789111",
          iso_country_code: "KH",
          marked_for_deletion: nil
        }
      )
    }.to raise_error(Errors::ImportError)
  end

  it "deletes a beneficiary" do
    import = create(:import)
    beneficiary = create(
      :beneficiary,
      phone_number: "85516789111",
      account: import.account
    )

    ImportBeneficiary.call(
      import:,
      data: {
        phone_number: "85516789111",
        marked_for_deletion: "true"
      }
    )

    expect(Beneficiary.find_by(id: beneficiary.id)).to eq(nil)
  end

  it "fails to delete a beneficiary if other attributes are given" do
    import = create(:import)
    create(
      :beneficiary,
      phone_number: "85516789111",
      account: import.account
    )

    expect {
      ImportBeneficiary.call(
        import:,
        data: {
          phone_number: "85516789111",
          marked_for_deletion: "true",
          iso_country_code: "KH"
        }
      )
    }.to raise_error(Errors::ImportError)
  end

  it "fails to delete a beneficiary not explicitly marked for deletion" do
    import = create(:import)
    create(
      :beneficiary,
      phone_number: "85516789111",
      account: import.account
    )

    expect {
      ImportBeneficiary.call(
        import:,
        data: {
          phone_number: "85516789111",
          marked_for_deletion: "X"
        }
      )
    }.to raise_error(Errors::ImportError)
  end

  it "fails to delete a beneficiary that does not exist" do
    import = create(:import)
    expect {
      ImportBeneficiary.call(
        import:,
        data: {
          phone_number: "85516789111",
          marked_for_deletion: "true"
        }
      )
    }.to raise_error(Errors::ImportError)
  end
end
