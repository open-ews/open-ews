module CountryAddressData
  class KH
    def self.address_data
      @address_data ||= Pumi::Province.all.map do |province|
        Locality.new(
          value: province.iso3166_2,
          name_en: province.name_latin,
          name_local: province.name_km,
          subdivisions: Pumi::District.where(province_id: province.id).map do |district|
            Locality.new(
              value: district.id,
              name_en: district.name_latin,
              name_local: district.name_km,
              subdivisions: Pumi::Commune.where(district_id: district.id).map do |commune|
                Locality.new(
                  value: commune.id,
                  name_en: commune.name_latin,
                  name_local: commune.name_km,
                  subdivisions: []
                )
              end
            )
          end
        )
      end
    end
  end
end
