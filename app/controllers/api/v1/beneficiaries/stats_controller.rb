module API
  module V1
    module Beneficiaries
      class StatsController < APIController
        def index
          validate_request_schema(
            with: ::V1::BeneficiaryStatsRequestSchema,
            serializer_class: StatSerializer,
            **serializer_options
          ) do |permitted_params|
            query_cache.fetch(permitted_params.slice(:filter, :group_by), scope_keys: current_account.cache_key) do
              StatsQuery.new(permitted_params).apply(scope)
            end
          end
        end

        private

        def scope
          current_account.beneficiaries
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

        def query_cache
          @query_cache ||= QueryCache.new
        end
      end
    end
  end
end
