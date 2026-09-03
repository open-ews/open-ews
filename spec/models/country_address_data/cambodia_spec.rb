require "rails_helper"

module CountryAddressData
  RSpec.describe Cambodia do
    it "returns address localities in Cambodia" do
      pumi_province = Pumi::Province.all.first
      pumi_district = Pumi::District.all.first
      pumi_commune = Pumi::Commune.all.first

      result = CountryAddressData.address_data(:KH)

      expect(result).to have_attributes(
        local_language: :km,
        localities: include(
          have_attributes(
            value: pumi_province.iso3166_2,
            name_en: pumi_province.name_en,
            name_local: pumi_province.name_km,
            subdivisions: include(
              have_attributes(
                value: pumi_district.id,
                name_en: pumi_district.name_en,
                name_local: pumi_district.name_km,
                subdivisions: include(
                  have_attributes(
                    value: pumi_commune.id,
                    name_en: pumi_commune.name_en,
                    name_local: pumi_commune.name_km
                  )
                )
              )
            )
          )
        )
      )
    end
  end
end
