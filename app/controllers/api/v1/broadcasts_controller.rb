module API
  module V1
    class BroadcastsController < APIController
      skip_before_action :doorkeeper_authorize!, only: [ :index, :show ]
      before_action -> { doorkeeper_authorize!(:write, :"read:broadcast") }, only: [ :index, :show ]

      def index
        apply_filters(scope.includes(include_parameter(only: [ :beneficiary_groups ])), with: BroadcastFilter)
      end

      def show
        respond_with_resource(scope.find(params[:id]))
      end

      def create
        validate_request_schema(with: ::V1::BroadcastRequestSchema) do |permitted_params|
          CreateBroadcast.call(account: current_account, **permitted_params)
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
