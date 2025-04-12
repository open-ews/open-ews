class JSONAPIRequestSchema < ApplicationRequestSchema
  option :resource, optional: true

  def self.attribute_rule(*args, &block)
    args = args.first if args.one?
    rule(data: { attributes: args }) do |context:|
      attributes = values.dig(:data, :attributes)
      instance_exec(attributes, context:, &block) if block_given?
    end
  end

  def self.error_serializer_class
    JSONAPIRequestSchemaErrorsSerializer
  end

  rule(data: :id) do
    next unless key?
    key([ :data, :id ]).failure("is invalid") if value != resource.id
  end

  def output
    output_data = super
    result = output_data.dig(:data, :attributes) || {}

    output_data.fetch(:data).fetch(:relationships, {}).each do |relationship, relationship_data|
      result[relationship] = Array(relationship_data.fetch(:data)).pluck(:id)
    end

    result
  end
end
