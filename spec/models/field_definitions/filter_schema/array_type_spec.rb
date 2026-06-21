require "rails_helper"

module FieldDefinitions
  module FilterSchema
    RSpec.describe ArrayType do
      it "supports `in` operator" do
        expect(validate_schema(build_schema, input: { in: [ "foo", "bar" ] })).to be_success
        expect(validate_schema(build_schema, input: { in: "foo" })).not_to be_success
        expect(validate_schema(build_schema(included_in: [ "bar" ]), input: { in: [ "foo", "bar" ] })).not_to be_success
      end

      it "supports `not_in` operator" do
        expect(validate_schema(build_schema, input: { not_in: [ "foo", "bar" ] })).to be_success
        expect(validate_schema(build_schema, input: { not_in: "foo" })).not_to be_success
        expect(validate_schema(build_schema(included_in: [ "bar" ]), input: { in: [ "foo", "bar" ] })).not_to be_success
      end

      it "whitelists supported operators" do
        schema = build_schema

        expect(schema.schema_definition.key_map.map(&:name)).to contain_exactly(
          "in",
          "not_in"
        )
      end

      def validate_schema(schema, input:)
        schema.schema_definition.call(input)
      end

      def build_schema(...)
        ArrayType.define(...)
      end
    end
  end
end
