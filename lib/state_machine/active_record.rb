module StateMachine
  class ActiveRecord < Machine
    attr_reader :record

    def initialize(record)
      @record = record
      super(record.status)
    end

    def transition_to(new_state)
      record.status = super.name
    end

    def transition_to!(new_state, **options)
      record.transaction do
        record.status = super(new_state).name
        record.save!
        timestamp_attribute = options.fetch(:touch) if options.key?(:touch)
        raise(ArgumentError, "Unknown timestamp attribute #{timestamp_attribute}") if timestamp_attribute.present? && !record.has_attribute?(timestamp_attribute)
        timestamp_attribute ||= "#{new_state}_at"
        record.touch(timestamp_attribute) if record.has_attribute?(timestamp_attribute)
      end
    end
  end
end
