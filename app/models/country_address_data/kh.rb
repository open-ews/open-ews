module CountryAddressData
  class KH
    def self.address_data
      @address_data ||= begin
        data = Pumi::Commune.all.each_with_object(Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = [] } }) do |commune, result|
          province_locality = CountryAddressData::Locality.new(
            value: commune.province.iso3166_2,
            name_en: commune.province.name_latin,
            name_local: commune.province.name_km,
            subdivisions: []
          )
          district_locality = CountryAddressData::Locality.new(
            value: commune.district.id,
            name_en: commune.district.name_latin,
            name_local: commune.district.name_km,
            subdivisions: []
          )
          commune_locality = CountryAddressData::Locality.new(
            value: commune.id,
            name_en: commune.name_latin,
            name_local: commune.name_km,
            subdivisions: []
          )

          result[province_locality][district_locality] << commune_locality
        end

        data.map do |province, districts|
          districts.each do |district, communes|
            communes.each do |commune|
              district.subdivisions << commune
            end

            province.subdivisions << district
          end

          province
        end
      end
    end
  end
end
