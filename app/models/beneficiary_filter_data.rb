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

    data.fields.reject { AddressTreeExpression.address?(it) }
  end

  private

  def address_tree_editable?
    address_elements.one? && address_tree_expression.valid?
  end

  def address_tree_expression
    AddressTreeExpression.new(address_elements.first)
  end

  def address_elements
    @address_elements ||= data.fields.select { AddressTreeExpression.address?(it) }
  end
end
