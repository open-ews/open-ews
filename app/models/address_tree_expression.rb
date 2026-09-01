class AddressTreeExpression
  NodeSelection = Data.define(:id, :level, :children) do
    def as_json
      {
        id:,
        level:,
        children: children.map(&:as_json)
      }
    end
  end

  attr_reader :filter

  def self.address?(element)
    if element.type.field?
      element.attributes[:administrative_level_identifier] && element.operator.in?([ :in, :eq ])
    else
      element.conditions.all? { address?(it) }
    end
  end

  def initialize(filter)
    @filter = filter
  end

  def valid?
    tree_expression?(filter)
  end

  def to_tree_selection(tree)
    return [] unless valid?

    selection_for(filter, tree)
  end

  private

  def tree_expression?(element)
    case element.operator
    when :or
      element.conditions.all? { tree_expression?(it) }
    when :and
      return tree_expression?(element.conditions.first) if element.conditions.one?

      levels = tree_path(element)
      levels.present? && levels.uniq.length == levels.length
    else
      address_field?(element)
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

  def address_field?(...)
    self.class.address?(...)
  end

  def selection_for(element, nodes)
    case element.operator
    when :or
      element.conditions.flat_map { selection_for(it, nodes) }
    when :and
      return selection_for(element.conditions.first) if element.conditions.one?

      selection_from_path(element.conditions, nodes)
    else
      selection_from_field(nodes:, level: address_level(element), value: element.value)
    end
  end

  def selection_from_field(nodes:, level:, value:)
    nodes.each_with_object([]) do |node, result|
      if node.level == level
        result << NodeSelection.new(id: node.id, level: node.level, children: []) if node.id.in?(Array(value))
      else
        children = selection_from_field(nodes: node.children, level:, value:)
        result << NodeSelection.new(id: node.id, level: node.level, children:) if children.any?
      end
    end
  end

  def selection_from_path(element, nodes)

  end
end
