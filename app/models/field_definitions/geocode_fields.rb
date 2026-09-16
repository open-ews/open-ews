module FieldDefinitions
  GeocodeFields = Collection.new(
      [
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
