class FilterDataType < ActiveRecord::Type::Json
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
        human_name: ApplicationRecord.human_attribute_name(field_definition.name),
        operator: FilterData::Operator.new(
          name: operator,
          human_name: I18n.t("filter_operators.#{operator}")
        ),
        value: FilterData::Value.new(
          actual_value: value,
          human_value: field_definition.schema.options.key?(:list_options) ? human_value_for_list_type(field_definition.schema.options_for_select, value) : value
        )
      )
    end

    FilterData.new(fields:)
  end

  def serialize(value)
    return super(value) unless value.is_a?(FilterData)

    result = value.fields.each_with_object({}) do |(_name, field), result|
      result[field.field_definition.path] = { field.operator.name => field.value.actual_value }
    end

    super(result)
  end

  private

  def human_value_for_list_type(options, value)
    return value if value.blank?

    if value.is_a?(Array)
      value.map { |v| options.find { it.last == v }.first }
    else
      options.find { it.last == value }.first
    end
  end
end
