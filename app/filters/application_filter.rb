class ApplicationFilter < ApplicationRequestSchema
  class_attribute :field_collection

  register_macro(:filter_conjunction) do |macro:|
    contract = macro.args[0].fetch(:with)
    next unless key?
    next key.failure(text: "must be a hash") unless value.is_a?(Hash)

    value.each do |condition_identifier, condition|
      next key([ *key.path, condition_identifier ]).failure(text: "must be a hash") unless condition.is_a?(Hash)

      contract_result = contract.new(input_params: condition)

      next if contract_result.success?

      contract_result.errors.each do |error|
        key([ *key.path, condition_identifier, *error.path ]).failure(error.text)
      end
    end
  end

  def self.has_fields(field_collection)
    self.field_collection = field_collection

    params do
      field_collection.each do |field|
        optional(field.path.to_sym).filled(:hash).schema(field.schema.schema_definition)
      end

      optional(:$and).value(:hash, min_size?: 1)
      optional(:$or).value(:hash, min_size?: 1)
    end

    rule(:$and).validate(filter_conjunction: { with: self })
    rule(:$or).validate(filter_conjunction: { with: self })
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
        filter_group = build_filter_group(operator: :and, conditions: val.values)
        conditions << filter_group if filter_group.present?
      when "$or"
        filter_group = build_filter_group(operator: :or, conditions: val.values) { |output| FilterGroup.new(operator: :and, conditions: output) }
        conditions << filter_group if filter_group.present?
      else
        operator, value = val.first
        field_definition = field_collection.find_by!(path: key)

        conditions << FilterField.new(field_definition:, operator:, value:)
      end
    end
  end

  def build_filter_group(operator:, conditions:)
    group_conditions = conditions.each_with_object([]) do |condition, result|
      output = self.class.new(input_params: condition).output
      result << (block_given? ? yield(output) : output) if output.present?
    end

    return if group_conditions.blank?

    FilterGroup.new(operator:, conditions: group_conditions)
  end
end
