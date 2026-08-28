class ApplicationFilter < ApplicationRequestSchema
  class_attribute :field_collection

  register_macro(:conjunction) do |macro:|
    schema = macro.args[0].fetch(:with_schema)
    next unless key?
    next key.failure(text: "must be a hash") unless value.is_a?(Hash)

    value.each do |condition_identifier, condition|
      next key([ *key.path, condition_identifier ]).failure(text: "must be a hash") unless condition.is_a?(Hash)

      schema_result = schema.new(input_params: condition)

      next if schema_result.success?

      schema_result.errors.each do |error|
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

    rule(:$and).validate(conjunction: { with_schema: self })
    rule(:$or).validate(conjunction: { with_schema: self })
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
      when "$and", "$or"
        operator = key.to_s.delete_prefix("$").to_sym

        group_conditions = val.values.each_with_object([]) do |condition, result|
          output = self.class.new(input_params: condition).output
          next if output.blank?

          if output.one?
            result << output.first
          else
            result << FilterGroup.new(
              operator: :and,
              conditions: output
            )
          end
        end

        conditions << FilterGroup.new(operator:, conditions: group_conditions) if group_conditions.present?
      else
        operator, value = val.first
        field_definition = field_collection.find_by!(path: key)

        conditions << FilterField.new(field_definition:, operator:, value:)
      end
    end
  end
end
