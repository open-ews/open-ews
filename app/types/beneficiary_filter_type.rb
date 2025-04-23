class BeneficiaryFilterType < ActiveRecord::Type::Value
  def cast(value)
    return value if value.is_a?(BroadcastForm::BeneficiaryFilter)

    result = (value || {}).each_with_object({}) do |(field, options), result|
      result[field] = {
        operator: options.first.first,
        value: options.first.last
      }
    end

    BroadcastForm::BeneficiaryFilter.new(result)
  end
end
