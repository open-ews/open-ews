class FilterForm < ApplicationForm
  class_attribute :filter_class

  def self.model_name
    ActiveModel::Name.new(self, nil, "Filter")
  end

  def self.attribute_definitions
    attributes.each_with_object({}) do |(name, _attribute_type), result|
      result[name] = filter_class.__field_collection__.find_by!(name:)
    end
  end

  def apply(scope)
    FilterScopeQuery.new(scope, normalized_filter_param).apply
  end

  private

  def normalized_filter_param
    serialized_filters = FilterFormType.new(
      form: self.class,
      field_definitions: filter_class.__field_collection__
    ).serialize(self)

    filter_class.new(
      input_params: serialized_filters
    ).output
  end
end
