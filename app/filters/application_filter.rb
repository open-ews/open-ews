class ApplicationFilter < ApplicationRequestSchema
  class_attribute :field_collection

  def self.has_fields(field_collection)
    self.field_collection = field_collection

    params do
      field_collection.each do |field|
        optional(field.path.to_sym).filled(:hash).schema(field.schema.schema_definition)
      end

      optional(:$and).filled(:hash)
      optional(:$or).filled(:hash)
    end

    rule(:$and) { _contract.class.validate_conjunction(self) }
    rule(:$or) { _contract.class.validate_conjunction(self) }
  end

  def self.validate_conjunction(evaluator)
    return unless evaluator.value.is_a?(Hash)

    evaluator.value.each do |identifier, item|
      unless item.is_a?(Hash) && item.present?
        evaluator.key([ *evaluator.key.path.to_a, identifier ]).failure("must be a hash")
        next
      end

      contract_result = new(input_params: item)
      next if contract_result.success?

      contract_result.errors.each do |error|
        evaluator.key([ *evaluator.key.path.to_a, identifier, *error.path ]).failure(error.text)
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

    build_conditions(filters)
  end

  private

  def build_conditions(filters)
    filters.each_with_object([]) do |(key, val), conditions|
      case key.to_s
      when "$and"
        conditions << FilterGroup.new(operator: :and, conditions: val.values.flat_map { |item| self.class.new(input_params: item).output })
      when "$or"
        conditions << FilterGroup.new(operator: :or, conditions: val.values.map { |item| FilterGroup.new(operator: :and, conditions: self.class.new(input_params: item).output) })
      else
        operator, value = val.first
        field_definition = field_collection.find_by!(path: key)

        conditions << FilterField.new(field_definition:, operator:, value:)
      end
    end
  end
end
