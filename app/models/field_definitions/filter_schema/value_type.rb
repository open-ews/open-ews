module FieldDefinitions
  module FilterSchema
    class ValueType < Base
      def self.define(type:)
        schema = Dry::Schema.Params do
          optional(:eq).filled(type)
          optional(:not_eq).filled(type)
          optional(:gt).filled(type)
          optional(:gteq).filled(type)
          optional(:lt).filled(type)
          optional(:lteq).filled(type)
          optional(:between).value(:array, size?: 2).each(type)
          optional(:is_null).filled(:bool, included_in?: [ true, false ])
        end

        new(
          schema_definition: schema,
          value_type: type
        )
      end
    end
  end
end
