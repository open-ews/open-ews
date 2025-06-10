module API
  module V1
    module Events
      class StatsController < APIController
        def index
          validate_request_schema(
            with: ::V1::EventStatsRequestSchema,
            serializer_class: StatSerializer,
            **serializer_options
          ) do |permitted_params|
              StatsQuery.new(permitted_params).apply(scope)
          end
        end

        private

        def scope
          current_account.events
        end

        def serializer_options
          {
            input_params: request.query_parameters,
            decorator_class: nil,
            serializer_options: {
              pagination: false
            }
          }
        end
      end
    end
  end
end
