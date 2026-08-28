class FilterDataType < ActiveRecord::Type::Value
  FilterData = Data.define(:fields, :groups)

  FilterData::Field = Data.define(
    :name,
    :operator,
    :value,
    :field_definition
  )

  FilterData::Group = Data.define(
    :operator,
    :conditions
  )

  attr_reader :field_definitions

  def initialize(field_definitions:, **)
    @field_definitions = field_definitions

    super(**)
  end

  def cast(value)
    return value if value.is_a?(FilterData)

    conditions = parse_conditions(Hash(value))

    fields = conditions
      .grep(FilterData::Field)
      .index_by(&:name)

    groups = conditions.grep(FilterData::Group)

    FilterData.new(fields:, groups:)
  end

  private

  def parse_conditions(hash)
    hash.flat_map do |key, value|
      case key.to_s
      when "$or"
        [ parse_group(:or, value) ]
      when "$and"
        parse_group_conditions(value)
      else
        [ parse_field(key, value) ]
      end
    end
  end

  def parse_group(operator, conditions)
    raise ArgumentError, "#{operator} must be a hash" unless conditions.is_a?(Hash)

    FilterData::Group.new(
      operator:,
      conditions: parse_group_conditions(conditions)
    )
  end

  def parse_group_conditions(conditions)
    conditions.flat_map do |key, condition|
      if conjunction?(key)
        parse_conditions(key => condition)
      else
        parse_conditions(condition)
      end
    end
  end

  def parse_field(key, filter_options)
    operator, value = filter_options.first

    field_definition = field_definitions.find_by!(path: key)

    FilterData::Field.new(
      field_definition:,
      name: field_definition.name,
      operator: operator.to_sym,
      value:
    )
  end

  def conjunction?(key)
    %w[$and $or].include?(key.to_s)
  end
end
