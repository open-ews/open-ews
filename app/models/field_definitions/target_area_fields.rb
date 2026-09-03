module FieldDefinitions
  TargetAreaFields = Collection.new(
    [
      Field.new(
        name: :iso_region_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:iso_region_code],
        association: :addresses,
        description: "An array of [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region codes of the target areas"
      ),
      Field.new(
        name: :administrative_division_level_2_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:administrative_division_level_2_code],
        association: :addresses,
        description: "An array of second-level administrative subdivision codes of the target areas (e.g. district codes)"
      ),
      Field.new(
        name: :administrative_division_level_3_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:administrative_division_level_3_code],
        association: :addresses,
        description: "An array of third-level administrative subdivision codes of the target areas (e.g. township codes)"
      ),
      Field.new(
        name: :administrative_division_level_4_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:administrative_division_level_4_code],
        association: :addresses,
        description: "An array of fourth-level administrative subdivision codes of the target areas (e.g. town codes)"
      ),
      Field.new(
        name: :administrative_division_level_5_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:administrative_division_level_5_code],
        association: :addresses,
        description: "An array of fifth-level administrative subdivision codes of the target areas (e.g. village codes)"
      )
    ]
  )
end
