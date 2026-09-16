module FieldDefinitions
  class GeocodeFilter < Filter
    class GeocodeFieldQuery < FieldQuery
      def to_arel(operator:, value:, scope:, **options)
        query_params = {
          administrative_level: options.fetch(:administrative_level),
          geocode: value
        }

        model_class = scope.klass
        query_builder = GeocodeQuery.new(model_class)

        query = case operator.to_sym
        when :eq
          query_builder.matching(**query_params)
        when :contains
          query_builder.contains(**query_params)
        end

        model_class.arel_table[:id].in(query.select(:id).arel)
      end
    end

    def self.build
      new(
        schema: FilterSchema::ArrayType.define(operators: [ :eq, :contains ]),
        query: GeocodeFieldQuery.new
      )
    end
  end
end
