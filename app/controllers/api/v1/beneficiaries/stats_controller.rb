module API
  module V1
    module Beneficiaries
      class StatsController < BaseController
        def index
          validate_request_schema(
            with: ::V1::BeneficiaryStatsRequestSchema,
            serializer_class: StatSerializer,
            **serializer_options
          ) do |permitted_params|
              StatsQuery.new(permitted_params).apply(beneficiaries_scope)
          end
        end

        private

        def beneficiaries_scope
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
      end
    end
  end
end
