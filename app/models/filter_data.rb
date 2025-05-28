class FilterData
  Field = Data.define(:name, :human_name, :operator, :value, :field_definition)
  Operator = Data.define(:name, :human_name)
  Value = Data.define(:actual_value, :human_value)

  attr_reader :fields

  def initialize(**options)
    @fields = options.fetch(:fields)
  end
end
