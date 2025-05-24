class BeneficiaryFilter < ApplicationFilter
  has_fields FieldDefinitions::BeneficiaryFields

  FIELDS_FOR_BROADCAST = [
    "gender",
    "disability_status",
    "disability_status"
  ].freeze
end
