class DeliveryAttempt < ApplicationRecord
  attribute :phone_number, :phone_number

  belongs_to :notification, counter_cache: true
  belongs_to :beneficiary
  belongs_to :broadcast

  delegate :account, to: :broadcast

  include MetadataHelpers

  delegate :initiated?, :transition_to!, :may_transition_to?, to: :state_machine

  class StateMachine < StateMachine::ActiveRecord
    state :created, initial: true, transitions_to: :queued
    state :queued, transitions_to: [ :initiated, :failed ]
    state :initiated, transitions_to: [ :failed, :succeeded ]
    state :failed
    state :succeeded
  end

  # NOTE: This is for backward compatibility until we moved to the new API
  def as_json(*)
    result = super
    result["msisdn"] = result.delete("phone_number")
    result["contact_id"] = result.delete("beneficiary_id")
    result
  end

  private

  def state_machine
    @state_machine ||= StateMachine.new(self)
  end
end
