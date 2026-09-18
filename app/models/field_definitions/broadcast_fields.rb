module FieldDefinitions
  BroadcastFields = Collection.new(
    [
      Field.new(
        name: "name",
        filter: Filter.new(
          schema: FilterSchema::StringType.define
        ),
        description: "The name of the broadcast."
      ),
      Field.new(
        name: "status",
        filter: Filter.new(
          schema: FilterSchema::ListType.define(type: :string, options: Broadcast.status.values),
        ),
        description: "Must be one of #{Broadcast.status.values.map { |t| "`#{t}`" }.join(", ")}."
      ),
      Field.new(
        name: "channels",
        filter: BroadcastFilter.channel,
        description: "Must be one of #{Broadcast.channel.values.map { |t| "`#{t}`" }.join(", ")}.",
      ),
      Field.new(
        name: "created_at",
        filter: Filter.timestamp,
        description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the broadcast was created."
      ),
      Field.new(
        name: "started_at",
        filter: Filter.timestamp,
        description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the broadcast was started."
      ),
      Field.new(
        name: "completed_at",
        filter: Filter.timestamp,
        description: "The [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) timestamp of when the broadcast was completed."
      ),
      *GeocodeFields
    ]
  )
end
