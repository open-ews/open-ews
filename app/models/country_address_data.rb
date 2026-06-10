module CountryAddressData
  Locality = Data.define(:value, :name_en, :name_local, :subdivisions)
  Configuration = Data.define(:address_field, :address_data)

  SETTINGS = {
    KH: Configuration.new(address_field: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_3_code), address_data: -> { CountryAddressData::Cambodia.new.address_data }),
    LA: Configuration.new(address_field: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_2_code), address_data: -> { CountryAddressData::Laos.new.address_data }),
    NP: Configuration.new(address_field: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_2_code), address_data: -> { CountryAddressData::Nepal.new.address_data }),
    MM: Configuration.new(address_field: FieldDefinitions::BeneficiaryFields.find_by!(name: :administrative_division_level_5_code), address_data: -> { CountryAddressData::Myanmar.new.address_data })
  }

  def self.address_field(iso_country_code)
    return nil unless supported?(iso_country_code)

    SETTINGS.fetch(iso_country_code.to_sym).address_field
  end

  def self.address_data(iso_country_code)
    return [] unless supported?(iso_country_code)

    SETTINGS.fetch(iso_country_code.to_sym).address_data.call
  end

  def self.supported?(iso_country_code)
    return false if iso_country_code.blank?

    SETTINGS.key?(iso_country_code.to_sym)
  end
end
