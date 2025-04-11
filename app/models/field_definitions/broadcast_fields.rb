module FieldDefinitions
  BroadcastFields = Collection.new([
    Field.new(name: "status", column: Broadcast.arel_table[:status], schema: FilterSchema::ListType.define(:string, Broadcast::StateMachine.state_definitions.map {  _1.name.to_s }), description: "Must be one of #{Broadcast::StateMachine.state_definitions.map { "`#{_1.name}`" }.join(", ")}."),
    Field.new(name: "channel", column: Broadcast.arel_table[:channel], schema: FilterSchema::ListType.define(:string, Broadcast.channel.values), description: "Must be one of #{Broadcast.channel.values.map { |t| "`#{t}`" }.join(", ")}.")
  ])
end
