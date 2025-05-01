module FieldDefinitions
  class Field
    OPERATORS = {
      eq: "Equals",
      not_eq: "Not Equals",
      contains: "Contains",
      not_contains: "Not Contains",
      starts_with: "Starts With",
      gt: "Greater Than",
      gteq: "Greater Than or Equal",
      lt: "Less Than",
      lteq: "Less Than or Equal",
      between: "Between",
      is_null: "Is NULL",
      in: "In",
      not_in: "Not In"
    }.freeze

    attr_reader :name, :column, :schema, :association, :description, :attributes

    def initialize(attributes)
      @name = attributes.fetch(:name)
      @column = attributes.fetch(:column)
      @schema = attributes.fetch(:schema)
      @association = attributes[:association]
      @description = attributes[:description]
      @attributes = attributes
    end

    def clone(overrides)
      self.class.new(attributes.merge(overrides))
    end

    def operator_options_for_select
      operators.map do |operator|
        [ OPERATORS[operator.to_sym], operator ]
      end
    end

    def operators
      schema.schema_definition.key_map.map do |key|
        key.name
      end
    end

    def field_type
      schema.type
    end
  end
end
