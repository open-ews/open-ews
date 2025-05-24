require "rails_helper"

RSpec.describe FieldDefinitions::FilterSchema::ValueType do
  it "supports `eq` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { eq: 1 })).to be_success
    expect(validate_schema(schema, input: { eq: nil })).not_to be_success
  end

  it "supports `not_eq` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { not_eq: 1 })).to be_success
    expect(validate_schema(schema, input: { not_eq: nil })).not_to be_success
  end

  it "supports `gt` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { gt: 1 })).to be_success
    expect(validate_schema(schema, input: { gt: nil })).not_to be_success
  end

  it "supports `gteq` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { gteq: 1 })).to be_success
    expect(validate_schema(schema, input: { gteq: nil })).not_to be_success
  end

  it "supports `lt` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { lt: 1 })).to be_success
    expect(validate_schema(schema, input: { lt: nil })).not_to be_success
  end

  it "supports `lteq` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { lteq: 1 })).to be_success
    expect(validate_schema(schema, input: { lteq: nil })).not_to be_success
  end

  it "supports `between` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { between: [ 1,  2 ] })).to be_success
    expect(validate_schema(schema, input: { between: nil })).not_to be_success
    expect(validate_schema(schema, input: { between: [ 1 ] })).not_to be_success
    expect(validate_schema(schema, input: { between: [ 1, 2, 3 ] })).not_to be_success
  end

  it "supports `is_null` operator" do
    schema = build_schema

    expect(validate_schema(schema, input: { is_null: true })).to be_success
    expect(validate_schema(schema, input: { is_null: false })).to be_success
    expect(validate_schema(schema, input: { is_null: nil })).not_to be_success
  end

  it "whitelists supported operators" do
    schema = build_schema

    expect(schema.schema_definition.key_map.map(&:name)).to contain_exactly(
      "eq",
      "not_eq",
      "gt",
      "gteq",
      "lt",
      "lteq",
      "between",
      "is_null"
    )
  end

  def validate_schema(schema, input:)
    schema.schema_definition.call(input)
  end

  def build_schema(type = :integer)
    FieldDefinitions::FilterSchema::ValueType.define(type)
  end
end
