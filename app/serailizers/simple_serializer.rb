module SimpleSerializer
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Serialization

    attr_reader :object
  end

  def initialize(object)
    @object = object
  end

  def as_json(*)
    self.class.serialized_attributes.each_with_object({}) do |(attribute_name, attribute_block), result|
      if attribute_block
        result[attribute_name] = attribute_block.call(object)
      else
        result[attribute_name] = object.public_send(attribute_name)
      end
    end
  end

  def as_hash
    as_json
  end

  def as_csv
    headers.map do |header|
      value = as_json[header.to_sym]

      case value
      when Hash
        value.to_json
      when Array
        value.join(", ")
      else
        value
      end
    end
  end

  def headers
    self.class.serialized_attributes.keys.map(&:to_s)
  end

  class_methods do
    def attributes(*names)
      names.each do |name|
        attribute(name)
      end
    end

    def timestamp_attributes(*names)
      names.each do |name|
        attribute(name) do |object|
          object.public_send(name).utc.iso8601 if object.public_send(name).present?
        end
      end
    end

    def attribute(name, &block)
      serialized_attributes[name.to_s.to_sym] = block
    end

    def serialized_attributes
      @serialized_attributes ||= begin
        if superclass.respond_to?(:serialized_attributes)
          superclass.serialized_attributes.dup
        else
          {}
        end
      end
    end
  end
end
