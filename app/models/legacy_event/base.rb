module LegacyEvent
  class Base
    include ActiveModel::Validations
    attr_accessor :eventable, :event

    validates :eventable, presence: true

    validates :event,
              inclusion: {
                in: :valid_events
              }

    def initialize(options = {})
      self.eventable = options[:eventable]
      self.event = options[:event]
    end

    def save
      if valid?
        fire_event!
      else
        false
      end
    end

    private

    def fire_event!
      eventable.aasm.fire!(event.to_sym)
    end

    def valid_events
      eventable && eventable.aasm.events.map { |event| event.name.to_s } || []
    end
  end
end
