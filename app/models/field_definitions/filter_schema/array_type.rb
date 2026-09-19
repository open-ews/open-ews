module FieldDefinitions
  module FilterSchema
    class ArrayType < Base
      def self.type
        "array".inquiry
      end

      def self.define(type: Dry.Types()::String, **options)
        value_type = options.key?(:included_in) ? type.enum(*Array(options[:included_in])) : type
        schema = Dry::Schema.Params do
          options.fetch(:operators, [ :eq, :contains ]).each do |operator|
            optional(operator).filled(value_type | Types::Array.of(value_type))
          end
        end

        new(
          schema_definition: schema,
          value_type: type,
          **options
        )
      end

      def options_for_select
        Array(options[:included_in]).map { [ it.text, it ] }
      end
    end
  end
end
