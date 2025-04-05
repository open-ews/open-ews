class Alert < ApplicationRecord
  include MetadataHelpers

  attribute :phone_number, :phone_number

  belongs_to :broadcast
  belongs_to :beneficiary

  has_many :delivery_attempts, dependent: :restrict_with_error

  has_many :remote_phone_call_events, through: :delivery_attempts

  delegate :call_flow_logic, to: :broadcast, prefix: true, allow_nil: true
  delegate :account, to: :broadcast

  before_create :set_phone_number

  class StateMachine
    class InvalidStateTransitionError < StandardError; end

    attr_reader :current_state

    State = Data.define(:name, :transitions_to)

    STATES = [
      State.new(name: :queued, transitions_to: [ :failed, :succeeded ]),
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

    def self.states
      STATES
    end
  end

  def self.still_trying(max_delivery_attempts)
    where.not(status: [ :failed, :succeeded ]).where(arel_table[:delivery_attempts_count].lt(max_delivery_attempts))
  end

  # NOTE: This is for backward compatibility until we moved to the new API
  def as_json(*)
    result = super
    result["msisdn"] = result.delete("phone_number")
    result["contact_id"] = result.delete("beneficiary_id")
    result["phone_calls_count"] = result.delete("delivery_attempts_count")
    result["answered"] = result.delete("status") == "succeeded"
    result
  end

  private

  def set_phone_number
    self.phone_number = beneficiary.phone_number
  end

  def state_machine
    @state_machine ||= StateMachine.new(status)
  end
end
