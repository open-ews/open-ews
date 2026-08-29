class BeneficiaryFilterData
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :data, FilterDataType.new(filter: BeneficiaryFilter)

  def address_filter
    return unless address_tree_editable?

    address_elements.first
  end

  def displayed_filters
    return data.fields unless address_tree_editable?

    data.fields.reject { address_expression?(it) }
  end

  private

  def address_tree_editable?
    address_elements.one?
  end

  def address_elements
    @address_elements ||= data.fields.select { address_expression?(it) }
  end

  def address_expression?(element)
    if element.type.field?
      element.field_definition.prefix&.address? && element.operator.in?([ :in, :eq ])
    else
      element.conditions.all? { address_expression?(it) }
    end
  end
end
