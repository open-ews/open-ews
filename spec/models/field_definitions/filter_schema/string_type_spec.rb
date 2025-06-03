require "rails_helper"

RSpec.describe FieldDefinitions::FilterSchema::StringType do
  it "supports `eq` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { eq: "foo" })).to be_success
    expect(validate_schema(schema, input: { eq: nil })).not_to be_success
  end

  it "supports `not_eq` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { not_eq: "foo" })).to be_success
    expect(validate_schema(schema, input: { not_eq: nil })).not_to be_success
  end

  it "supports `is_null` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { is_null: true })).to be_success
    expect(validate_schema(schema, input: { is_null: false })).to be_success
    expect(validate_schema(schema, input: { is_null: nil })).not_to be_success
  end

  it "supports `contains` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { contains: "foo" })).to be_success
    expect(validate_schema(schema, input: { contains: nil })).not_to be_success
  end

  it "supports `not_contains` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { not_contains: "foo" })).to be_success
    expect(validate_schema(schema, input: { not_contains: nil })).not_to be_success
  end

  it "supports `starts_with` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { starts_with: "foo" })).to be_success
    expect(validate_schema(schema, input: { starts_with: nil })).not_to be_success
  end

  it "supports `in` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { in: [ "foo", "bar" ] })).to be_success
    expect(validate_schema(schema, input: { in: "foo" })).not_to be_success
  end

  it "supports `not_in` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { not_in: [ "foo", "bar" ] })).to be_success
    expect(validate_schema(schema, input: { not_in: "foo" })).not_to be_success
  end

  it "whitelists supported operators" do
    schema = build_schema

    expect(schema.schema_definition.key_map.map(&:name)).to contain_exactly(
      "eq",
      "not_eq",
      "contains",
      "not_contains",
      "starts_with",
      "is_null",
      "in",
      "not_in"
    )
  end

  it "supports custom types" do
    schema = build_schema(type: FieldDefinitions::Types::UpcaseString)

    result = validate_schema(schema, input: { eq: "kh" })

    expect(result).to be_success
    expect(result.to_h).to eq(eq: "KH")
  end

  def validate_schema(schema, input:)
    schema.schema_definition.call(input)
  end

  def build_schema(...)
    FieldDefinitions::FilterSchema::StringType.define(...)
  end
end
