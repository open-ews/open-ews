module Event
  class Callout < Event::Base
    private

    def fire_event!
      case event.to_sym
      when :start, :resume
        eventable.transition_to!(:running) if eventable.may_transition_to?(:running)
      when :stop, :pause
        eventable.transition_to!(:stopped) if eventable.may_transition_to?(:stopped)
      end
    end

    def valid_events
      [ "start", "stop", "pause", "resume" ]
    end
  end
end
