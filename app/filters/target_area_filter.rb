class TargetAreaFilter < ApplicationFilter
  def self.has_fields(field_collection)
    self.field_collection = field_collection

    params do
      optional(:geocode).array(:hash) do
        field_collection.where(category: :geocode).each do |field|
          optional(field.path.to_sym).filled(:str?)
        end
      end
    end

    rule(:geocode).each do
      levels = value.keys
              .map { FieldDefinitions::TargetAreaFields.find_by!(name: it).attributes.fetch(:administrative_level) }
              .sort

      next if levels == (1..levels.size).to_a

      key.failure("must include contiguous administrative levels starting at level 1")
    end
  end

  has_fields FieldDefinitions::TargetAreaFields

  private

  def build_filter_group(filters)
    areas = Array(filters[:geocode]).map do |area|
      fields = area.map do |field_name, value|
        field_definition = FieldDefinitions::TargetAreaFields.find_by!(name: field_name)
        FilterField.new(field_definition:, operator: :eq, value:)
      end
      FilterGroup.new(conditions: fields, conjunction: :and)
    end
    FilterGroup.new(conditions: areas, conjunction: :or)
  end
end
