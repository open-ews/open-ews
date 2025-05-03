require_relative "beneficiary_fields"

module FieldDefinitions
  BROADCAST_BENEFICIARY_FIELDS = [
    "gender",
    "disability_status",
    "date_of_birth",
    "language_code",
    "address.iso_region_code",
    "address.administrative_division_level_2_code",
    "address.administrative_division_level_2_name",
    "address.administrative_division_level_3_code",
    "address.administrative_division_level_3_name",
    "address.administrative_division_level_4_code",
    "address.administrative_division_level_4_name"
  ]

  BroadcastBeneficiaryFields = Collection.new(
    BeneficiaryFields.select { |f| BROADCAST_BENEFICIARY_FIELDS.include?(f.name) }
  )
end
