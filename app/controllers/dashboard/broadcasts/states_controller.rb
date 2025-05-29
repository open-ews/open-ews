module Dashboard
  module Broadcasts
    class StatesController < Dashboard::BaseController
      def create
        @broadcast = current_account.broadcasts.find(params[:broadcast_id])
        broadcast_state_machine = BroadcastStateMachine.new(@broadcast.status)

        if broadcast_state_machine.may_transition_to?(params[:desired_status])
          UpdateBroadcast.call(
            @broadcast,
            desired_status: broadcast_state_machine.transition_to!(
              params.fetch(:desired_status)
            ).name
          )

          respond_with(:dashboard, @broadcast)
        else
          redirect_to action: :show, error: "Invalid state transition"
        end
      end
    end
  end
end
