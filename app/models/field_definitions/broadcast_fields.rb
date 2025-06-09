module FieldDefinitions
  BroadcastFields = Collection.new(
    [
      Field.new(name: "status", column: Broadcast.arel_table[:status], schema: FilterSchema::ListType.define(type: :string, options: Broadcast.status.values), description: "Must be one of #{Broadcast.status.values.map { |t| "`#{t}`" }.join(", ")}."),
      Field.new(name: "channel", column: Broadcast.arel_table[:channel], schema: FilterSchema::ListType.define(type: :string, options: Broadcast.channel.values), description: "Must be one of #{Broadcast.channel.values.map { |t| "`#{t}`" }.join(", ")}."),
      Field.new(name: "created_at", column: Broadcast.arel_table[:created_at], schema: FilterSchema::ValueType.define(type: :time), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the broadcast was created."),
      Field.new(name: "started_at", column: Broadcast.arel_table[:started_at], schema: FilterSchema::ValueType.define(type: :time), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the broadcast was started."),
      Field.new(name: "completed_at", column: Broadcast.arel_table[:completed_at], schema: FilterSchema::ValueType.define(type: :time), description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the broadcast was completed.")
    ]
  )
end
