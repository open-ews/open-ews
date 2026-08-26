class ApplicationFilter < ApplicationRequestSchema
  class_attribute :field_collection

  def self.has_fields(field_collection)
    self.field_collection = field_collection

    params do
      field_collection.each do |field|
        optional(field.path.to_sym).filled(:hash).schema(field.schema.schema_definition)
      end

      optional(:$and).value(:array, min_size?: 1).each(:hash)
      optional(:$or).value(:array, min_size?: 1).each(:hash)
    end

    rule(:$and).each { _contract.class.validate_conjunction(self) }
    rule(:$or).each { _contract.class.validate_conjunction(self) }
  end

  def self.validate_conjunction(evaluator)
    return unless evaluator.value.is_a?(Hash)

    contract_result = new(input_params: evaluator.value)
    return if contract_result.success?

    contract_result.errors.each do |error|
      evaluator.key([ *evaluator.key.path.to_a, *error.path ]).failure(error.text)
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

    build_conditions(filters)
  end

  private

  def build_conditions(filters)
    filters.each_with_object([]) do |(key, val), conditions|
      case key.to_s
      when "$and"
        conditions << FilterGroup.new(operator: :and, conditions: val.flat_map { |item| self.class.new(input_params: item).output })
      when "$or"
        conditions << FilterGroup.new(operator: :or, conditions: val.map { |item| as_single_condition(self.class.new(input_params: item).output) })
      else
        operator, value = val.first
        field_definition = field_collection.find_by!(path: key)

        conditions << FilterField.new(field_definition:, operator:, value:)
      end
    end
  end

  def as_single_condition(conditions)
    return conditions.first if conditions.size == 1

    FilterGroup.new(operator: :and, conditions:)
  end
end
