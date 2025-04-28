class Alert < ApplicationRecord
  include MetadataHelpers

  attribute :phone_number, :phone_number

  belongs_to :broadcast
  belongs_to :beneficiary

  has_many :delivery_attempts

  delegate :account, to: :broadcast
  delegate :transition_to!, to: :state_machine

  before_create :set_phone_number

  class StateMachine < StateMachine::ActiveRecord
    state :pending, initial: true, transitions_to: [ :failed, :succeeded ]
    state :failed
    state :succeeded
  end

  def completed?
    completed_at.present?
  end

  def max_delivery_attempts_reached?
    delivery_attempts_count >= account.max_delivery_attempts_for_alert
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
    @state_machine ||= StateMachine.new(self)
  end
end
