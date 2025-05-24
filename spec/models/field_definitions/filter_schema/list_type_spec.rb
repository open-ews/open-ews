require "rails_helper"

RSpec.describe FieldDefinitions::FilterSchema::ListType do
  it "supports `eq` operator" do
    schema = build_schema(options: [ "foo", "bar" ])

    expect(validate_schema(schema, input: { eq: "foo" })).to be_success
    expect(validate_schema(schema, input: { eq: nil })).not_to be_success
    expect(validate_schema(schema, input: { eq: "invalid" })).not_to be_success
  end

  it "supports `not_eq` operator" do
    schema = build_schema(options: [ "foo", "bar" ])

    expect(validate_schema(schema, input: { not_eq: "foo" })).to be_success
    expect(validate_schema(schema, input: { not_eq: nil })).not_to be_success
    expect(validate_schema(schema, input: { not_eq: "invalid" })).not_to be_success
  end

  it "supports `is_null` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { is_null: true })).to be_success
    expect(validate_schema(schema, input: { is_null: false })).to be_success
    expect(validate_schema(schema, input: { is_null: nil })).not_to be_success
  end

  it "supports `in` operator" do
    schema = build_schema(options: [ "foo", "bar" ])

    expect(validate_schema(schema, input: { in: [ "foo", "bar" ] })).to be_success
    expect(validate_schema(schema, input: { in: [ "foo" ] })).to be_success
    expect(validate_schema(schema, input: { in: [ "foo", "baz" ] })).not_to be_success
  end

  it "supports `not_in` operator" do
    schema = build_schema(options: [ "foo", "bar" ])

    expect(validate_schema(schema, input: { not_in: [ "foo", "bar" ] })).to be_success
    expect(validate_schema(schema, input: { not_in: [ "foo" ] })).to be_success
    expect(validate_schema(schema, input: { not_in: [ "foo", "baz" ] })).not_to be_success
  end

  it "whitelists supported operators" do
    schema = build_schema

    expect(schema.key_map.map(&:name)).to contain_exactly(
      "eq",
      "not_eq",
      "is_null",
      "in",
      "not_in"
    )
  end

  def build_schema(type: :string, options: [ "foo", "bar" ])
    FieldDefinitions::FilterSchema::ListType.define(type, options)
  end

  def validate_schema(schema, input:)
    schema.schema_definition.call(input)
  end
end
