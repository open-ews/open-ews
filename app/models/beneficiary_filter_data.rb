class BeneficiaryFilterData
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :data, FilterDataType.new(filter: BeneficiaryFilter)

  def has_address_fields?
    data.fields.any? { address_field?(it) }
  end

  private

  def address_field?(field)
    if field.type.field?
      field.address?
    else
      field.conditions.any? { address_field?(it) }
    end
  end
end
