module FieldDefinitions
  BeneficiaryFields = Collection.new([
    Field.new(
      name: :phone_number,
      column: Beneficiary.arel_table[:phone_number],
      schema: FilterSchema::StringType.define,
      description: "The phone number of the beneficiary.",
      required: true,
      example: "85516200101"
    ),
    Field.new(
      name: :status,
      column: Beneficiary.arel_table[:status],
      schema: FilterSchema::ListType.define(type: :string, options: Beneficiary.status.values),
      description: "Must be one of #{Beneficiary.status.values.map { |t| "`#{t}`" }.join(", ")}."
    ),
    Field.new(
      name: :gender,
      column: Beneficiary.arel_table[:gender],
      schema: FilterSchema::ListType.define(type: Types::UpcaseString, options: Beneficiary.gender.values),
      description: "Must be one of `M` or `F`."
    ),
    Field.new(
      name: :disability_status,
      column: Beneficiary.arel_table[:disability_status],
      schema: FilterSchema::ListType.define(type: :string, options: Beneficiary.disability_status.values),
      description: "Must be one of #{Beneficiary.disability_status.values.map { |t| "`#{t}`" }.join(", ")}."
    ),
    Field.new(
      name: :date_of_birth,
      column: Beneficiary.arel_table[:date_of_birth],
      schema: FilterSchema::ValueType.define(type: :date),
      description: "Date of birth in `YYYY-MM-DD` format."
    ),
    Field.new(
      name: :iso_language_code,
      column: Beneficiary.arel_table[:iso_language_code],
      schema: FilterSchema::StringType.define(type: :string, length: 3),
      description: "The [ISO 639-2](https://en.wikipedia.org/wiki/List_of_ISO_639-3_codes) alpha-3 language code of the beneficiary."
    ),
    Field.new(
      name: :iso_country_code,
      column: Beneficiary.arel_table[:iso_country_code],
      schema: FilterSchema::CountryListType.define(type: Types::UpcaseString, options: Beneficiary.iso_country_code.values),
      description: "The [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the beneficiary.",
      required: true,
      example: "KH"
    ),
    Field.new(
      name: :created_at,
      column: Beneficiary.arel_table[:created_at],
      schema: FilterSchema::ValueType.define(type: :date_time, form_value_type: :date),
      description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the beneficiary was created.",
      read_only: true
    ),
    Field.new(
      name: :iso_region_code,
      prefix: :address,
      column: BeneficiaryAddress.arel_table[:iso_region_code],
      schema: FilterSchema::StringType.define,
      association: :addresses,
      description: "The [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region code of the address"
    ),
    Field.new(
      name: :administrative_division_level_2_code,
      prefix: :address,
      column: BeneficiaryAddress.arel_table[:administrative_division_level_2_code],
      schema: FilterSchema::StringType.define,
      association: :addresses,
      description: "The second-level administrative subdivision code of the address (e.g. district code)"
    ),
    Field.new(
      name: :administrative_division_level_2_name,
      prefix: :address,
      column: BeneficiaryAddress.arel_table[:administrative_division_level_2_name],
      schema: FilterSchema::StringType.define,
      association: :addresses,
      description: "The second-level administrative subdivision name of the address (e.g. district name)"
    ),
    Field.new(
      name: :administrative_division_level_3_code,
      prefix: :address,
      column: BeneficiaryAddress.arel_table[:administrative_division_level_3_code],
      schema: FilterSchema::StringType.define,
      association: :addresses,
      description: "The third-level administrative subdivision code of the address (e.g. commune code)"
    ),
    Field.new(
      name: :administrative_division_level_3_name,
      prefix: :address,
      column: BeneficiaryAddress.arel_table[:administrative_division_level_3_name],
      schema: FilterSchema::StringType.define,
      association: :addresses,
      description: "The third-level administrative subdivision name of the address (e.g. commune name)"
    ),
    Field.new(
      name: :administrative_division_level_4_code,
      prefix: :address,
      column: BeneficiaryAddress.arel_table[:administrative_division_level_4_code],
      schema: FilterSchema::StringType.define,
      association: :addresses,
      description: "The forth-level administrative subdivision code of the address (e.g. village code)"
    ),
    Field.new(
      name: :administrative_division_level_4_name,
      prefix: :address,
      column: BeneficiaryAddress.arel_table[:administrative_division_level_4_name],
      schema: FilterSchema::StringType.define,
      association: :addresses,
      description: "The forth-level administrative subdivision name of the address (e.g. village name)"
    )
  ])
end
