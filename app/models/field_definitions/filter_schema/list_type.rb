module FieldDefinitions
  module FilterSchema
    class ListType < Base
      def self.define(type:, options:)
        schema = Dry::Schema.Params do
          optional(:eq).filled(type, included_in?: options)
          optional(:not_eq).filled(type, included_in?: options)
          optional(:in).array(type, included_in?: options)
          optional(:not_in).array(type, included_in?: options)
          optional(:is_null).filled(:bool, included_in?: [ true, false ])
        end

        new(
          schema_definition: schema,
          value_type: type,
          list_options: options
        )
      end
    end
  end
end
