module FieldDefinitions
  module FilterSchema
    class Base
      attr_reader :schema_definition, :input_type, :type, :options

      def initialize(schema_definition:, input_type:, type:, **options)
        @schema_definition = schema_definition
        @input_type = input_type
        @type = type
        @options = options
      end
    end
  end
end
