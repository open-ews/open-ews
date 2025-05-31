module LegacyEvent
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :eventable
    attribute :event

    validates :eventable, presence: true

    validates :event,
              inclusion: {
                in: :valid_events
              }

    def save
      if valid?
        fire_event!
        true
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
