class BeneficiaryFilterData
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :data, FilterDataType.new(field_definitions: FieldDefinitions::BeneficiaryFields)
  attribute :address_data_field_definition

  def address_data_field
    data.fields.values.find { it.field_definition == address_data_field_definition }
  end
end
