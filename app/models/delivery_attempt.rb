class DeliveryAttempt < ApplicationRecord
  TWILIO_CALL_STATUSES = {
    queued: "queued",
    in_progress: "in-progress",
    canceled: "canceled",
    completed: "completed",
    busy: "busy",
    failed: "failed",
    not_answered: "no-answer"
  }.freeze

  IN_PROGRESS_STATUSES = %i[remotely_queued in_progress].freeze

  attribute :phone_number, :phone_number

  belongs_to :alert, counter_cache: true
  belongs_to :beneficiary
  belongs_to :broadcast

  delegate :account, to: :broadcast

  include MetadataHelpers

  delegate :initiated?, to: :state_machine

  before_destroy    :validate_destroy

  class StateMachine
    class InvalidStateTransitionError < StandardError; end

    attr_reader :current_state

    State = Data.define(:name, :transitions_to)

    STATES = [
      State.new(name: :created, transitions_to: [ :queued ]),
      State.new(name: :queued, transitions_to: [ :initiated, :errored ]),
      State.new(name: :initiated, transitions_to: [ :failed, :busy, :not_answered, :canceled, :completed, :expired ]),
      State.new(name: :errored, transitions_to: []),
      State.new(name: :failed, transitions_to: []),
      State.new(name: :busy, transitions_to: []),
      State.new(name: :not_answered, transitions_to: []),
      State.new(name: :canceled, transitions_to: []),
      State.new(name: :completed, transitions_to: []),
      State.new(name: :expired, transitions_to: [])
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

  def transition_to!(new_state)
    transaction do
      self.status = state_machine.transition_to!(new_state)
      save!
      touch("#{new_state}_at") if has_attribute?("#{new_state}_at")
    end
  end

  def may_transition_to?(new_state)
    state_machine.may_transition_to?(new_state)
  end

  private

  def state_machine
    @state_machine ||= StateMachine.new(status)
  end

  def remote_status_in_progress?
    [
      TWILIO_CALL_STATUSES.fetch(:in_progress),
      TWILIO_CALL_STATUSES.fetch(:ringing)
    ].include?(remote_status)
  end

  def validate_destroy
    return true if created?

    errors.add(:base, :restrict_destroy_status, status: status)
    throw(:abort)
  end
end
