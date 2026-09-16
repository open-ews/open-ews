class GeocodeQuery
  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def matching(...)
    scope.joins(:geocode_target_areas)
    .merge(GeocodeTargetArea.where(...))
    .where.not(id: GeocodeTargetArea.outside(...).select(:broadcast_id)).distinct
  end

  def contains(...)
    scope.joins(:geocode_target_areas).merge(GeocodeTargetArea.where(...))
  end
end
