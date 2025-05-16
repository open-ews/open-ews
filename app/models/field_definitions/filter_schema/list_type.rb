module FieldDefinitions
  module FilterSchema
    class ListType < Base
      def self.define(type, values)
        schema = Dry::Schema.Params do
          optional(:eq).filled(type, included_in?: values)
          optional(:not_eq).filled(type, included_in?: values)
          optional(:in).array(type, included_in?: values)
          optional(:not_in).array(type, included_in?: values)
          optional(:is_null).filled(:bool, included_in?: [ true, false ])
        end

        new(
          schema_definition: schema,
          input_type: type,
          type: :list,
          options: values
        )
      end
    end
  end
end
