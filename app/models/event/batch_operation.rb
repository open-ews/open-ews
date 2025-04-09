module Event
  class BatchOperation < Event::Base
    private

    def fire_event!
      eventable.transaction do
        eventable.broadcast.transition_to!(:queued)
        eventable.aasm.fire!(event.to_sym)
      end
    end

    def valid_events
      super & %w[queue]
    end
  end
end
