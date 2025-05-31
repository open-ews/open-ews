module Dashboard
  module Broadcasts
    class StatesController < DashboardController
      def create
        @broadcast = current_account.broadcasts.find(params[:broadcast_id])
        broadcast_state_machine = BroadcastStateMachine.new(@broadcast.status)

        UpdateBroadcast.call(
          @broadcast,
          desired_status: broadcast_state_machine.transition_to!(
            params.fetch(:desired_status)
          ).name
        )

        respond_with(:dashboard, @broadcast)
      end
    end
  end
end
