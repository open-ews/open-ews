module API
  module V1
    class EventsController < BaseController
      def index
        apply_filters(scope, with: EventFilter)
      end

      def show
        respond_with_resource(scope.find(params[:id]))
      end

      private

      def scope
        current_account.events
      end
    end
  end
end
