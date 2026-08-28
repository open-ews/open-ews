class FilterDataType < ActiveRecord::Type::Value
  FilterData = Data.define(:fields)

  attr_reader :filter

  def initialize(filter:, **)
    @filter = filter

    super(**)
  end

  def cast(value)
    return value if value.is_a?(FilterData)

    FilterData.new(
      fields: filter.new(input_params: value).output
    )
  end
end
