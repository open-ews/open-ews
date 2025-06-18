require "rails_helper"

RSpec.describe SimpleSerializer do
  serializer_class = Class.new do
    include SimpleSerializer

    has_associations :foo, :bar
    has_associations :baz

    attributes :name, :email, :created_at, :updated_at

    timestamp_attributes :created_at

    attribute :updated_at do |object|
      object.updated_at.utc.iso8601
    end

    attribute :hash_attr do |object|
      { name: object.name, email: object.email }
    end

    attribute :array_attr do |object|
      [ object.name, object.email ]
    end
  end

  describe "#associations" do
    it "returns the associations" do
      expect(serializer_class.associations).to eq([ :foo, :bar, :baz ])
    end
  end

  describe "#as_json" do
    it "returns a hash with the serialized attributes" do
      object = OpenStruct.new(
        name: "John Doe",
        email: "john.doe@example.com",
        created_at: Time.now,
        updated_at: Time.now
      )

      serializer = serializer_class.new(object)

      expect(serializer.as_json).to eq(
        name: "John Doe",
        email: "john.doe@example.com",
        created_at: object.created_at.utc.iso8601,
        updated_at: object.updated_at.utc.iso8601,
        hash_attr: { name: "John Doe", email: "john.doe@example.com" },
        array_attr: [ "John Doe", "john.doe@example.com" ]
      )
    end
  end

  describe "#as_csv" do
    it "returns a CSV string with the serialized attributes" do
      object = OpenStruct.new(
        name: "John Doe",
        email: "john.doe@example.com",
        created_at: Time.now,
        updated_at: Time.now
      )

      serializer = serializer_class.new(object)

      expect(serializer.headers).to eq([ "name", "email", "created_at", "updated_at", "hash_attr", "array_attr" ])
      expect(serializer.as_csv).to eq(
        [
          "John Doe",
          "john.doe@example.com",
          object.created_at.utc.iso8601,
          object.updated_at.utc.iso8601,
          { name: "John Doe", email: "john.doe@example.com" }.to_json,
          [ "John Doe", "john.doe@example.com" ].to_json
        ]
      )
    end
  end
end
