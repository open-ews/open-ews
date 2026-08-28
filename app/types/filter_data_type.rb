class FilterDataType < ActiveRecord::Type::Value
  FilterData = Data.define(:fields)

  FilterData::Field = Data.define(
    :name,
    :operator,
    :value,
    :field_definition,
    :type
  ) do
    def address?
      field_definition.prefix&.address?
    end
  end

  FilterData::Group = Data.define(
    :operator,
    :conditions,
    :type
  )

  attr_reader :filter

  def initialize(filter:, **)
    @filter = filter

    super(**)
  end

  def cast(value)
    return value if value.is_a?(FilterData)

    filters = filter.new(input_params: value).output
    filters
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
      type: "group".inquiry,
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
      type: "field".inquiry,
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
