require "rails_helper"

module CSVSerializers
  RSpec.describe BeneficiarySerializer do
    it "serializes the beneficiary attributes" do
      beneficiary = create(
        :beneficiary,
        phone_number: "85510555123",
        gender: "F",
        status: "active",
        disability_status: "normal",
        iso_language_code: "khm",
        date_of_birth: Date.new(1990, 1, 1),
        iso_country_code: "KH"
      )
      create(
        :beneficiary_address,
        beneficiary:,
        iso_region_code: "KH-12",
        administrative_division_level_2_code: "1201",
        administrative_division_level_3_code: "120101",
        administrative_division_level_4_code: "12010101"
      )
      create(
        :beneficiary_address,
        beneficiary:,
        iso_region_code: "KH-13",
        administrative_division_level_2_code: "1301",
        administrative_division_level_3_code: "130101",
        administrative_division_level_4_code: "13010101"
      )

      result = BeneficiarySerializer.new(beneficiary).as_json

      expect(result[:phone_number]).to eq("85510555123")
      expect(result[:gender]).to eq("F")
      expect(result[:status]).to eq("active")
      expect(result[:disability_status]).to eq("normal")
      expect(result[:iso_language_code]).to eq("khm")
      expect(result[:date_of_birth]).to eq(Date.new(1990, 1, 1))
      expect(result[:iso_country_code]).to eq("KH")

      expect(result[:addresses].size).to eq(2)
      expect(result[:addresses][0][:iso_region_code]).to eq("KH-12")
      expect(result[:addresses][0][:administrative_division_level_2_code]).to eq("1201")
      expect(result[:addresses][0][:administrative_division_level_3_code]).to eq("120101")
      expect(result[:addresses][0][:administrative_division_level_4_code]).to eq("12010101")
      expect(result[:addresses][1][:iso_region_code]).to eq("KH-13")
      expect(result[:addresses][1][:administrative_division_level_2_code]).to eq("1301")
      expect(result[:addresses][1][:administrative_division_level_3_code]).to eq("130101")
      expect(result[:addresses][1][:administrative_division_level_4_code]).to eq("13010101")
    end
  end
end
