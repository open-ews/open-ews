class FilterDataType < ActiveRecord::Type::Value
  FilterData = Data.define(:fields)
  FilterData::Field = Data.define(:type, :name, :operator, :value, :field_definition, :attributes, :conditions)

  attr_reader :filter

  def initialize(filter:, **)
    @filter = filter

    super(**)
  end

  def cast(value)
    return value if value.is_a?(FilterData)

    fields = filter.new(input_params: value).output
    FilterData.new(fields: fields.map { parse_field(it) })
  end

  private

  def parse_field(field)
    case field
    when FilterField
      type = "field".inquiry
      field_definition = field.field_definition
      name = field_definition.name
      attributes = field_definition.attributes
      value = field.value
      conditions = []
    when FilterGroup
      type = "group".inquiry
      attributes = {}
      conditions = field.conditions.map { parse_field(it) }
    end

    FilterData::Field.new(
      type:,
      name:,
      field_definition:,
      operator: field.operator,
      value:,
      attributes:,
      conditions:
    )
  end
end
