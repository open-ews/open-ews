module CountryAddressData
  Locality = Data.define(:value, :name_en, :name_local, :subdivisions)
  Configuration = Data.define(:local_language, :localities_data) do
    def localities
      localities_data.call
    end
  end

  SETTINGS = {
    KH: Configuration.new(local_language: :km, localities_data: -> { CountryAddressData::Cambodia.address_data }),
    LA: Configuration.new(local_language: :lo, localities_data: -> { CountryAddressData::Laos.address_data }),
    NP: Configuration.new(local_language: :ne, localities_data: -> { CountryAddressData::Nepal.address_data }),
    MM: Configuration.new(local_language: :my, localities_data: -> { CountryAddressData::Myanmar.address_data })
  }

  def self.address_data(iso_country_code)
    return [] unless supported?(iso_country_code)

    SETTINGS.fetch(iso_country_code.to_sym)
  end

  def self.supported?(iso_country_code)
    return false if iso_country_code.blank?

    SETTINGS.key?(iso_country_code.to_sym)
  end
end
