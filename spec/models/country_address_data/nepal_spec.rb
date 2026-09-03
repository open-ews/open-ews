require "rails_helper"

module CountryAddressData
  RSpec.describe Nepal do
    it "returns address localities in Nepal" do
      gaun_province = Gaun::Province.all.first
      gaun_district = gaun_province.districts.first

      result = CountryAddressData.address_data(:NP)

      expect(result).to have_attributes(
        local_language: :ne,
        localities: include(
          have_attributes(
            value: gaun_province.code,
            name_en: gaun_province.name_en,
            name_local: gaun_province.name_ne,
            subdivisions: include(
              have_attributes(
                value: gaun_district.code,
                name_en: gaun_district.name_en,
                name_local: gaun_district.name_ne,
              )
            )
          )
        )
      )
    end
  end
end
