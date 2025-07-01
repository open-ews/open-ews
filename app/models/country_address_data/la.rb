module CountryAddressData
  class LA
    def self.address_data
      @address_data ||= Baan::Province.all.map do |province|
        CountryAddressData::Locality.new(
          value: province.code,
          name_en: province.name_en,
          name_local: province.name_lo,
          subdivisions: province.districts.map do |district|
            CountryAddressData::Locality.new(
              value: district.code,
              name_en: district.name_en,
              name_local: district.name_lo,
              subdivisions: []
            )
          end
        )
      end
    end
  end
end
