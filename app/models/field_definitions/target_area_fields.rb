module FieldDefinitions
  TargetAreaFields = Collection.new(
    [
      Field.new(
        name: :iso_region_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:iso_region_code],
        association: :addresses,
        description: "The [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region code of the target area"
      ),
      Field.new(
        name: :administrative_division_level_2_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:administrative_division_level_2_code],
        association: :addresses,
        description: "The second-level administrative subdivision code of the target area (e.g. district code)"
      ),
      Field.new(
        name: :administrative_division_level_3_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:administrative_division_level_3_code],
        association: :addresses,
        description: "The third-level administrative subdivision code of the target area (e.g. township code)"
      ),
      Field.new(
        name: :administrative_division_level_4_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:administrative_division_level_4_code],
        association: :addresses,
        description: "The fourth-level administrative subdivision code of the target area (e.g. town code)"
      ),
      Field.new(
        name: :administrative_division_level_5_code,
        category: :geocode,
        column: BeneficiaryAddress.arel_table[:administrative_division_level_5_code],
        association: :addresses,
        description: "The fifth-level administrative subdivision code of the target area (e.g. village code)"
      )
    ]
  )
end
