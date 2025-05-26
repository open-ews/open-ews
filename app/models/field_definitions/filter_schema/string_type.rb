module FieldDefinitions
  module FilterSchema
    class StringType < Base
      def self.define(type: :string, **options)
        schema = Dry::Schema.Params do
          optional(:eq).filled(type)
          optional(:not_eq).filled(type)
          optional(:contains).filled(type)
          optional(:not_contains).filled(type)
          optional(:starts_with).filled(type)
          optional(:in).array(type)
          optional(:not_in).array(type)
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
