module CountryAddressData
  Locality = Data.define(:value, :name_en, :name_local, :subdivisions)

  SETTINGS = {
    KH: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_3_code),
    LA: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_2_code),
    NP: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_2_code),
    MM: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_5_code)
  }

  def self.address_field(iso_country_code)
    SETTINGS[iso_country_code.to_sym]
  end

  def self.supported?(iso_country_code)
    return false if iso_country_code.blank?

    SETTINGS.key?(iso_country_code.to_sym)
  end

  def self.address_data(iso_country_code)
    return [] unless supported?(iso_country_code)

    CountryAddressData.const_get(iso_country_code).address_data
  end
end
