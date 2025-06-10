class ApplicationFilter < ApplicationRequestSchema
  class_attribute :field_collection

  def self.has_fields(field_collection)
    self.field_collection = field_collection

    params do
      field_collection.each do |field|
        optional(field.path.to_sym).filled(:hash).schema(field.schema.schema_definition)
      end
    end
  end

  def self.filter_contract
    this = self
    @filter_contract ||= Class.new(this) do
      params do
        optional(:filter).schema(this.schema)
      end

      rule(:filter).validate(contract: this)

      def output
        return {} if result[:filter].blank?

        self.class.superclass.new(input_params: result[:filter]).output
      end
    end
  end

  def output
    filters = super
    return {} if filters.blank?

    filters.map do |(filter, condition)|
      operator, value = condition.first
      field_definition = field_collection.find_by!(path: filter)

      FilterField.new(field_definition:, operator:, value:)
    end
  end
end
