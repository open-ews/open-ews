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
        filter: Filter.new(
          schema: FilterSchema::ArrayType.define(included_in: Broadcast.channel.values),
          query: FieldQuery.new(
            arel_column: Broadcast.arel_table[:channel],
          )
        ),
        description: "Must be one of #{Broadcast.status.values.map { |t| "`#{t}`" }.join(", ")}.",
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
      Field.new(
        name: :iso_region_code,
        prefix: "target_areas.geocode",
        filter: GeocodeFilter.build,
        description: "The [ISO 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) region code of the target area",
        metadata: {
          administrative_level: 1
        }
      ),
      Field.new(
        name: :administrative_division_level_2_code,
        prefix: "target_areas.geocode",
        filter: GeocodeFilter.build,
        description: "The second-level administrative subdivision code of the target area (e.g. district code)",
        metadata: {
          administrative_level: 2
        }
      ),
      Field.new(
        name: :administrative_division_level_3_code,
        prefix: "target_areas.geocode",
        filter: GeocodeFilter.build,
        description: "The third-level administrative subdivision code of the target area (e.g. township code)",
        metadata: {
          administrative_level: 3
        }
      ),
      Field.new(
        name: :administrative_division_level_4_code,
        prefix: "target_areas.geocode",
        filter: GeocodeFilter.build,
        description: "The fourth-level administrative subdivision code of the target area (e.g. town code)",
        metadata: {
          administrative_level: 4
        }
      ),
      Field.new(
        name: :administrative_division_level_5_code,
        prefix: "target_areas.geocode",
        filter: GeocodeFilter.build,
        description: "The fifth-level administrative subdivision code of the target area (e.g. village code)",
        metadata: {
          administrative_level: 5
        }
      )
    ]
  )
end
