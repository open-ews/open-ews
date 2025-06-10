module API
  module V1
    module Broadcasts
      module Notifications
        class StatsController < APIController
          def index
            validate_request_schema(
              with: ::V1::NotificationStatsRequestSchema,
              serializer_class: StatSerializer,
              **serializer_options
            ) do |permitted_params|
                StatsQuery.new(permitted_params).apply(notifications_scope)
              end
          end

          private

          def broadcast
            @broadcast ||= current_account.broadcasts.find(params[:broadcast_id])
          end

          def notifications_scope
            broadcast.notifications
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
end
