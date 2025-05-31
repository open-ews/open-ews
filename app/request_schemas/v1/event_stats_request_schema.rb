module V1
  class EventStatsRequestSchema < ApplicationRequestSchema
    GROUPS = [ "type" ].freeze

    params do
      optional(:filter).schema(EventFilter.schema)
      required(:group_by).value(:array).each(:string, included_in?: GROUPS)
    end

    rule(:filter).validate(contract: EventFilter)

    def output
      result = super

      if result[:filter]
        result[:filter_fields] = EventFilter.new(input_params: result[:filter]).output
      end

      result[:group_by_fields] = result[:group_by].map do |group|
        FieldDefinitions::EventFields.find_by!(path: group)
      end

      result
    end
  end
end
