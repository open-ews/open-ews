class FilterScopeQuery
  attr_reader :scope, :filter_fields, :conjunction

  def initialize(scope, filter_fields, **options)
    @scope = scope
    @filter_fields = filter_fields
    @conjunction = options.fetch(:conjunction, :and)
  end

  def apply
    scope.left_joins(joins_with).where(conditions).distinct
  end

  private

  def joins_with
    filter_fields.map(&:association).compact_blank.uniq
  end

  def conditions
    filter_fields.map(&:to_query).reduce(conjunction)
  end
end
