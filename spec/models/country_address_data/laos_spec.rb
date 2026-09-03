require "rails_helper"

module CountryAddressData
  RSpec.describe Laos do
    it "returns address localities in Laos" do
      baan_province = Baan::Province.all.first
      baan_district = baan_province.districts.first

      result = CountryAddressData.address_data(:LA)

      expect(result).to have_attributes(
        local_language: :lo,
        localities: include(
          have_attributes(
            value: baan_province.code,
            name_en: baan_province.name_en,
            name_local: baan_province.name_lo,
            subdivisions: include(
              have_attributes(
                value: baan_district.code,
                name_en: baan_district.name_en,
                name_local: baan_district.name_lo
              )
            )
          )
        )
      )
    end
  end
end
