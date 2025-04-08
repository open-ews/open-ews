module Event
  class Callout < Event::Base
    private

    def fire_event!
      case event.to_sym
      when :start, :resume
        if broadcast_status_validator.may_transition_to?(:running)
          eventable.transition_to!(broadcast_status_validator.transition_to!(:running).name)
        end
      when :stop, :pause
        if broadcast_status_validator.may_transition_to?(:stopped)
          eventable.transition_to!(broadcast_status_validator.transition_to!(:stopped).name)
        end
      end
    end

    def valid_events
      [ "start", "stop", "pause", "resume" ]
    end

    def broadcast_status_validator
      @broadcast_status_validator ||= BroadcastStatusValidator.new(eventable)
    end
  end
end
