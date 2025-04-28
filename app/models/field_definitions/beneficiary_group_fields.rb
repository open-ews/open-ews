module FieldDefinitions
  BeneficiaryGroupFields = Collection.new(
    [
      Field.new(
        name: "name",
        column: BeneficiaryGroup.arel_table[:name],
        schema: FilterSchema::StringType.define,
        description: "A friendly name for the group."
      )
    ]
  )
end
