module FieldDefinitions
  alerts = Alert.arel_table

  AlertFields = Collection.new([
    Field.new(name: "status", column: alerts[:status], schema: FilterSchema::ListType.define(:string, Alert::StateMachine.states.map { _1.name.to_s }), description: "Must be one of #{Alert::StateMachine.states.map { "`#{_1.name}`" }.join(", ")}."),
    Field.new(name: "delivery_attempts_count", column: alerts[:delivery_attempts_count], schema: FilterSchema::ValueType.define(:integer), description: "Number of delivery attempts"),

    *BeneficiaryFields.map do |field|
      field.clone(name: "beneficiary.#{field.name}", association: { beneficiary: field.association })
    end
  ])
end
