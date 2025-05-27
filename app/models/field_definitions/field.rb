module FieldDefinitions
  class Field
    OPERATORS = %i[
      eq
      not_eq
      contains
      not_contains
      starts_with
      gt
      gteq
      lt
      lteq
      between
      is_null
      in
      not_in
    ].freeze

    MULTIPLE_SELECTION_OPERATORS = %w[in not_in]

    attr_reader :name, :prefix, :path, :column, :schema, :association, :description, :example, :attributes

    def initialize(attributes)
      @name = attributes.fetch(:name)
      @prefix = ActiveSupport::StringInquirer.new(attributes[:prefix]) if attributes.key?(:prefix)
      @path = attributes[:path] = [ prefix, name ].compact.join(".")
      @column = attributes.fetch(:column)
      @schema = attributes.fetch(:schema)
      @association = attributes[:association]
      @description = attributes[:description]
      @read_only = attributes.fetch(:read_only, false)
      @required = attributes.fetch(:required, false)
      @example = attributes[:example]
      @attributes = attributes
    end

    def read_only?
      !!@read_only
    end

    def required?
      !!@required
    end

    def clone(overrides)
      self.class.new(attributes.merge(overrides))
    end

    def operator_options_for_select
      operators.map do |operator|
        [ I18n.t(:"filter_operators.#{operator}"), operator ]
      end
    end

    def value_options_for_select(model)
      attributes = model.enumerized_attributes.attributes

      return schema.options.fetch(:list_options) unless attributes.keys.include?(name)

      attributes.fetch(name).values.map { [ it.text, it.value ] }
    end

    def operators
      schema.schema_definition.key_map.map do |key|
        key.name
      end
    end
  end
end
