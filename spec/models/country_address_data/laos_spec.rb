require "rails_helper"

module CountryAddressData
  RSpec.describe Laos do
    it "returns address localities in Laos" do
      result = Laos.new.address_data

      expect(result).to be_an(Array)
      expect(result[0]).to be_a(CountryAddressData::Locality)

      first_province = Baan::Province.all.first
      expect(result[0]).to have_attributes(
        value: first_province.code,
        name_en: first_province.name_en,
        name_local: first_province.name_lo,
      )

      first_district = first_province.districts.first
      expect(result[0].subdivisions[0]).to be_a(CountryAddressData::Locality)
      expect(result[0].subdivisions[0]).to have_attributes(
        value: first_district.code,
        name_en: first_district.name_en,
        name_local: first_district.name_lo,
      )
    end
  end
end
