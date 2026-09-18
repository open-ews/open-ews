module FieldDefinitions
  class BroadcastFilter < Filter
    class ChannelFieldQuery < FieldQuery
      def to_arel(operator:, value:, **)
        filter_value = Array(value)

        case operator
        when :eq
          arel_column.eq(filter_value.join("."))
        when :contains
          arel_column.in(filter_value)
        end
      end
    end

    def self.channel
      new(
        schema: FilterSchema::ArrayType.define(included_in: Broadcast.channel.values, operators: [ :eq, :contains ]),
        query: ChannelFieldQuery.new(
          arel_column: Broadcast.arel_table[:channel],
        )
      )
    end
  end
end
