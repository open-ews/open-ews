module FieldDefinitions
  module FilterSchema
    class ValueType < Base
      def self.define(type:, **options)
        schema = Dry::Schema.Params do
          optional(:eq).filled(type, **Hash(options[:type_options]))
          optional(:not_eq).filled(type, **Hash(options[:type_options]))
          optional(:gt).filled(type, **Hash(options[:type_options]))
          optional(:gteq).filled(type, **Hash(options[:type_options]))
          optional(:lt).filled(type, **Hash(options[:type_options]))
          optional(:lteq).filled(type, **Hash(options[:type_options]))
          optional(:between).value(:array, size?: 2).each(type, **Hash(options[:type_options]))
          optional(:is_null).filled(:bool, included_in?: [ true, false ])
        end

        new(
          schema_definition: schema,
          value_type: type,
          **options
        )
      end
    end
  end
end
