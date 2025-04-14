module FieldDefinitions
  AlertFields = Collection.new([
    Field.new(name: "status", column: Alert.arel_table[:status], schema: FilterSchema::ListType.define(:string, Alert::StateMachine.state_definitions.map { _1.name.to_s }), description: "Must be one of #{Alert::StateMachine.state_definitions.map { "`#{_1.name}`" }.join(", ")}."),
    Field.new(name: "delivery_attempts_count", column: Alert.arel_table[:delivery_attempts_count], schema: FilterSchema::ValueType.define(:integer), description: "Number of delivery attempts"),
    Field.new(name: "created_at", column: Alert.arel_table[:created_at], schema: FilterSchema::ValueType.define(:time), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the alert was created."),
    Field.new(name: "completed_at", column: Alert.arel_table[:created_at], schema: FilterSchema::ValueType.define(:time), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the alert was completed."),

    *BeneficiaryFields.map do |field|
      field.clone(name: "beneficiary.#{field.name}", association: { beneficiary: field.association })
    end
  ])
end
