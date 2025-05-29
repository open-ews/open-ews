class FilterDataType < ActiveRecord::Type::Json
  FilterData = Data.define(:fields)
  FilterData::Field = Data.define(:name, :operator, :value, :field_definition)

  attr_reader :field_definitions

  def initialize(**options)
    @field_definitions = options.delete(:field_definitions)
    super(**options)
  end

  def deserialize(value)
    cast(super(value))
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

  def serialize(value)
    return super(value) unless value.is_a?(FilterData)

    result = value.fields.each_with_object({}) do |(_name, field), result|
      result[field.field_definition.path] = { field.operator => field.value }
    end

    super(result)
  end
end
