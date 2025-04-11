module FieldDefinitions
  AlertFields = Collection.new([
    Field.new(name: "status", column: Alert.arel_table[:status], schema: FilterSchema::ListType.define(:string, Alert::StateMachine.state_definitions.map { _1.name.to_s }), description: "Must be one of #{Alert::StateMachine.state_definitions.map { "`#{_1.name}`" }.join(", ")}."),
    Field.new(name: "delivery_attempts_count", column: Alert.arel_table[:delivery_attempts_count], schema: FilterSchema::ValueType.define(:integer), description: "Number of delivery attempts"),

    *BeneficiaryFields.map do |field|
      field.clone(name: "beneficiary.#{field.name}", association: { beneficiary: field.association })
    end
  ])
end
