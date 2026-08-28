class FilterGroup
  attr_reader :operator, :conditions

  def initialize(operator:, conditions:)
    @operator = operator
    @conditions = conditions
  end

  def to_query
    conditions.map(&:to_query).reduce(operator)
  end

  def associations
    conditions.flat_map(&:associations)
  end

  def type
    "group".inquiry
  end
end
