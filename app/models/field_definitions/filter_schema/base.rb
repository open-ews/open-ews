module FieldDefinitions
  module FilterSchema
    class Base
      attr_reader :schema_definition, :base_type, :type, :options

      def initialize(schema_definition:, base_type:, type:, options: nil)
        @schema_definition = schema_definition
        @base_type = base_type
        @type = type

        @options = options
      end
    end
  end
end
