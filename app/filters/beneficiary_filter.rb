class BeneficiaryFilter < ApplicationFilter
  has_fields FieldDefinitions::BeneficiaryFields

  IGNORE_FIELDS_FOR_BROADCAST = [
    "status",
    "iso_country_code"
  ].freeze
end
