class FilterData
  Field = Data.define(:name, :operator, :value, :field_definition)

  Operator = Data.define(:name) do
    def human_name
      I18n.t("filter_operators.#{name}")
    end
  end

  Value = Data.define(:actual_value, :human_value)

  attr_reader :fields

  def initialize(fields:)
    @fields = fields
  end
end
