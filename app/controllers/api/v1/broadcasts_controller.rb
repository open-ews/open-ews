module API
  module V1
    class BroadcastsController < BaseController
      def index
        apply_filters(scope, with: BroadcastFilter)
      end

      def show
        respond_with_resource(scope.find(params[:id]))
      end

      def create
        validate_request_schema(with: ::V1::BroadcastRequestSchema) do |permitted_params|
          CreateBroadcast.call(scope, **permitted_params)
        end
      end

      def update
        broadcast = scope.find(params[:id])

        validate_request_schema(
          with: ::V1::UpdateBroadcastRequestSchema,
          schema_options: { resource: broadcast },
        ) do |permitted_params|
          UpdateBroadcast.call(broadcast, **permitted_params)
        end
      end

      private

      def scope
        current_account.broadcasts
      end
    end
  end
end
