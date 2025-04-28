class JSONAPIRequestSchema < ApplicationRequestSchema
  option :resource, optional: true

  def self.attribute_rule(*args, &block)
    args = args.first if args.one?
    rule(data: { attributes: args }) do |context:|
      attributes = values.fetch(:data).fetch(:attributes, {})
      relationships = values.fetch(:data).fetch(:relationships, {})
      instance_exec(attributes:, relationships:, context:, &block) if block_given?
    end
  end

  def self.relationship_rule(relationship_name, &block)
    rule(data: { relationships: { relationship_name => :data } }) do |context:|
      attributes = values.fetch(:data).fetch(:attributes, {})
      relationships = values.fetch(:data).fetch(:relationships, {})
      relationship = relationships.dig(relationship_name, :data)
      instance_exec(attributes:, relationships:, relationship:, context:, &block) if block_given?
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
