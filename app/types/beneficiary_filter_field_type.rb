class BeneficiaryFilterFieldType < ActiveRecord::Type::Value
  def cast(value)
    return value if value.is_a?(BroadcastForm::BeneficiaryFilterField)

    BroadcastForm::BeneficiaryFilterField.new(value)
  end
end
