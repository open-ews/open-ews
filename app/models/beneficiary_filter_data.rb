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
    address_elements.one?  && tree_expression?(address_elements.first)
  end

  def address_elements
    @address_elements ||= data.fields.select { address_expression?(it) }
  end

  def address_expression?(element)
    if element.type.field?
      address_field?(element)
    else
      element.conditions.all? { address_expression?(it) }
    end
  end

  def address_field?(field)
    field.field_definition.attributes[:administrative_level_identifier] && field.operator.in?([ :in, :eq ])
  end

  def tree_expression?(element)
    return address_field?(element) if element.type.field?

    case element.operator
    when :or
      element.conditions.all? { tree_expression?(it) }
    when :and
      return tree_expression?(element.conditions.first) if element.conditions.one?

      levels = tree_path(element)
      levels.present? && levels.uniq.length == levels.length
    end
  end

  def tree_path(element)
    return address_level(element) if element.type.field?
    return unless element.operator == :and

    paths = element.conditions.map { tree_path(it) }

    return unless paths.all?

    paths.flatten
  end

  def address_level(field)
    field.attributes.fetch(:administrative_level)
  end
end
