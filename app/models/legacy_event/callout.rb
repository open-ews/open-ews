module LegacyEvent
  class Callout < Base
    private

    def fire_event!
      if [ :start, :resume ].include?(event.to_sym)
        # Don't allow this event if the callout is pending or queued
        # This will happen automatically when the batch operation is queued
        return if [ "pending", "queued" ].include?(eventable.status)

        if broadcast_status_validator.may_transition_to?(:running)
          eventable.transition_to!(broadcast_status_validator.transition_to!(:running).name)
        end
      elsif [ :stop, :pause ].include?(event.to_sym) && broadcast_status_validator.may_transition_to?(:stopped)
        eventable.transition_to!(broadcast_status_validator.transition_to!(:stopped).name)
      end
    end

    def valid_events
      [ "start", "stop", "pause", "resume" ]
    end

    def broadcast_status_validator
      @broadcast_status_validator ||= BroadcastStatusValidator.new(eventable.status)
    end
  end
end
