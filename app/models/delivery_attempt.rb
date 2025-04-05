class DeliveryAttempt < ApplicationRecord
  attribute :phone_number, :phone_number

  belongs_to :alert, counter_cache: true
  belongs_to :beneficiary
  belongs_to :broadcast

  delegate :account, to: :broadcast

  include MetadataHelpers

  delegate :initiated?, to: :state_machine

  class StateMachine
    class InvalidStateTransitionError < StandardError; end

    attr_reader :current_state

    State = Data.define(:name, :transitions_to)

    STATES = [
      State.new(name: :created, transitions_to: [ :queued ]),
      State.new(name: :queued, transitions_to: [ :initiated, :errored ]),
      State.new(name: :initiated, transitions_to: [ :failed, :succeeded ]),
      State.new(name: :errored, transitions_to: []),
      State.new(name: :failed, transitions_to: []),
      State.new(name: :succeeded, transitions_to: [])
    ]

    def initialize(current_state)
      @current_state = self.class.find(current_state)
    end

    def transition_to(new_state)
      may_transition_to?(new_state) ? new_state : current_state.name
    end

    def transition_to!(new_state)
      may_transition_to?(new_state) ? transition_to(new_state) : raise(InvalidStateTransitionError.new("Cannot transition from #{current_state.name} to #{new_state}"))
    end

    def may_transition_to?(new_state)
      current_state.transitions_to.include?(new_state.to_s.to_sym)
    end

    STATES.each do |state|
      define_method("#{state.name}?", -> { current_state.name == state.name })
    end

    def self.find(state)
      STATES.find(-> { raise ArgumentError, "Unknown state #{state}" }) { _1.name == state.to_s.to_sym }
    end
  end

  # NOTE: This is for backward compatibility until we moved to the new API
  def as_json(*)
    result = super
    result["msisdn"] = result.delete("phone_number")
    result["contact_id"] = result.delete("beneficiary_id")
    result
  end

  def transition_to(new_state)
    self.status = state_machine.transition_to(new_state)
  end

  def transition_to!(new_state, **options)
    transaction do
      self.status = state_machine.transition_to!(new_state)
      save!
      timestamp_attribute = options.fetch(:touch) if options.key?(:touch)
      raise(ArgumentError, "Unknown timestamp attribute #{timestamp_attribute}") if timestamp_attribute.present? && !has_attribute?(timestamp_attribute)
      timestamp_attribute ||= "#{new_state}_at"
      touch(timestamp_attribute) if has_attribute?(timestamp_attribute)
    end
  end

  def may_transition_to?(new_state)
    state_machine.may_transition_to?(new_state)
  end

  private

  def state_machine
    @state_machine ||= StateMachine.new(status)
  end
end
