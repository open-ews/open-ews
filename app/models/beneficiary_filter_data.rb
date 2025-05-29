class BeneficiaryFilterData
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :data, FilterDataType.new(field_definitions: FieldDefinitions::BeneficiaryFields)
  attribute :address_data_field_name

  def address_fields
    @address_fields ||= data.fields.each_with_object({}) do |(_name, field), result|
      next unless field.field_definition.prefix&.address?

      result[field.name] = field
    end
  end

  def address_data_field
    fields = address_fields.values
    return unless fields.one?

    fields.first if fields.first.name == address_data_field_name
  end
end
