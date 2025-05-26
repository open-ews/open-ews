class BroadcastForm::BeneficiaryFilterFieldType < ActiveRecord::Type::Value
  attr_reader :field_definition

  def initialize(**options)
    @field_definition = options.delete(:field_definition)
    super(**options)
  end

  def cast(value)
    return value if value.is_a?(BroadcastForm::BeneficiaryFilterField)

    BroadcastForm::BeneficiaryFilterField.new(value)
  end
end
