module SerializableResource
  extend ActiveSupport::Concern

  included do
    delegate :jsonapi_serializer_class, to: :class
  end

  module ClassMethods
    def jsonapi_serializer_class
      "#{model_name}Serializer".constantize
    end

    def csv_serializer_class
      CSVSerializers.const_get("#{model_name}Serializer")
    end
  end
end
