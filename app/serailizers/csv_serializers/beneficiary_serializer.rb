module CSVSerializers
  class BeneficiarySerializer < ResourceSerializer
    has_associations :addresses

    attributes :phone_number, :gender, :status, :disability_status, :iso_language_code, :date_of_birth, :iso_country_code

    attribute :addresses do |object|
      object.addresses.map do |address|
        BeneficiaryAddressSerializer.new(address).as_json
      end
    end
  end
end
