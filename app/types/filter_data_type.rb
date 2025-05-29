class FilterDataType < ActiveRecord::Type::Value
  FilterData = Data.define(:fields)
  FilterData::Field = Data.define(:name, :operator, :value, :field_definition)

  attr_reader :field_definitions

  def initialize(field_definitions:, **)
    @field_definitions = field_definitions
    super(**)
  end

  def cast(value)
    return value if value.is_a?(FilterData)

    fields = (value || {}).each_with_object({}) do |(key, filter_options), result|
      operator, value = filter_options.first
      field_definition = field_definitions.find_by!(path: key)

      result[field_definition.name] = FilterData::Field.new(
        field_definition:,
        name: field_definition.name,
        operator:,
        value:
      )
    end

    FilterData.new(fields:)
  end
end
