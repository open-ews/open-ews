module CountryAddressData
  Locality = Data.define(:value, :name_en, :name_local, :subdivisions)

  SETTINGS = {
    kh: :administrative_division_level_3_code,
    la: :administrative_division_level_2_code
  }

  def self.supported?(iso_country_code)
    SETTINGS.key?(iso_country_code.to_sym)
  end

  def self.address_data(iso_country_code)
    return [] unless supported?(iso_country_code)

    CountryAddressData.const_get(iso_country_code.upcase).address_data
  end
end
