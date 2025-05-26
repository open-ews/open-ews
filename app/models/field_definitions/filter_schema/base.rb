module FieldDefinitions
  module FilterSchema
    class Base
      attr_reader :schema_definition, :value_type, :options

      def initialize(schema_definition:, value_type:, **options)
        @schema_definition = schema_definition
        @value_type = value_type
        @options = options
      end
    end
  end
end
