class BroadcastForm::BeneficiaryFilterType < ActiveRecord::Type::Value
  def cast(value)
    return value if value.is_a?(BroadcastForm::BeneficiaryFilter)

    result = (value || {}).each_with_object({}) do |(field, options), result|
      key = field.split(".").last

      result[key] = {
        operator: options.first.first,
        value: options.first.last
      }
    end

    BroadcastForm::BeneficiaryFilter.new(result)
  end

  def serialize(value)
    return value unless value.is_a?(BroadcastForm::BeneficiaryFilter)

    value.attributes.each_with_object({}) do |(name, filter), result|
      next if filter.blank?

      field_definition = BroadcastForm::BeneficiaryFilter.type_for_attribute(name).field_definition
      result[field_definition.name] = { filter.operator => filter.value }
    end
  end
end
