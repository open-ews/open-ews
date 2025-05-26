module FieldDefinitions
  NotificationFields = Collection.new([
    Field.new(name: "status", column: Notification.arel_table[:status], schema: FilterSchema::ListType.define(type: :string, options: Notification::StateMachine.state_definitions.map { it.name.to_s }), description: "Must be one of #{Notification::StateMachine.state_definitions.map { "`#{it.name}`" }.join(", ")}."),
    Field.new(name: "delivery_attempts_count", column: Notification.arel_table[:delivery_attempts_count], schema: FilterSchema::ValueType.define(type: :integer), description: "Number of delivery attempts"),
    Field.new(name: "created_at", column: Notification.arel_table[:created_at], schema: FilterSchema::ValueType.define(type: :time), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the notification was created."),
    Field.new(name: "completed_at", column: Notification.arel_table[:created_at], schema: FilterSchema::ValueType.define(type: :time), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the notification was completed."),

    *BeneficiaryFields.map do |field|
      field.clone(name: "beneficiary.#{field.name}", association: { beneficiary: field.association })
    end
  ])
end
