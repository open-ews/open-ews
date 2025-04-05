class UpdateDeliveryAttemptStatus < ApplicationWorkflow
  attr_reader :delivery_attempt, :status

  def initialize(delivery_attempt, status:)
    @delivery_attempt = delivery_attempt
    @status = status
  end

  def call
    case status
    when "completed"
      delivery_attempt.transition_to!(:succeeded, touch: :completed_at)
    when "busy", "no-answer", "failed", "canceled"
      delivery_attempt.transition_to!(:failed, touch: :completed_at)
    end
  end
end
