module LegacyEvent
  class Callout < Base
    private

    def fire_event!
      if [ :start, :resume ].include?(event.to_sym)
        # Don't allow this event if the callout is pending or queued
        # This will happen automatically when the batch operation is queued
        return if [ "pending", "queued" ].include?(eventable.status)

        if broadcast_state_machine.may_transition_to?(:running)
          eventable.transition_to!(broadcast_state_machine.transition_to!(:running).name)
        end
      elsif [ :stop, :pause ].include?(event.to_sym) && broadcast_state_machine.may_transition_to?(:stopped)
        eventable.transition_to!(broadcast_state_machine.transition_to!(:stopped).name)
      end
    end

    def valid_events
      [ "start", "stop", "pause", "resume" ]
    end

    def broadcast_state_machine
      @broadcast_state_machine ||= BroadcastStateMachine.new(eventable.status)
    end
  end
end
