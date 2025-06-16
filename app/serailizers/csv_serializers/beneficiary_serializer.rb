module CSVSerializers
  class BeneficiarySerializer < ResourceSerializer
    attributes :phone_number, :gender, :status, :disability_status, :iso_language_code, :date_of_birth, :iso_country_code

    # FIXME: add addresses
  end
end
