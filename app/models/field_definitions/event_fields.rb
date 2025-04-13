module FieldDefinitions
  EventFields = Collection.new(
    [
      Field.new(
        name: "type",
        column: Event.arel_table[:type],
        schema: FilterSchema::ListType.define(:string, Event.type.values),
        description: "The event type. Must be one of #{Event.type.values.map { "`#{_1}`" }.join(", ")}."
      ),
      Field.new(
        name: "created_at",
        column: Event.arel_table[:created_at],
        schema: FilterSchema::ValueType.define(:time),
        description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of the event."
      )
    ]
  )
end
