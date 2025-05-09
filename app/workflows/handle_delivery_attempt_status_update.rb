class HandleDeliveryAttemptStatusUpdate < ApplicationWorkflow
  attr_reader :delivery_attempt, :status

  def initialize(delivery_attempt, status:)
    @delivery_attempt = delivery_attempt
    @status = status
  end

  def call
    ApplicationRecord.transaction do
      case status
      when "completed"
        delivery_attempt.transition_to!(:succeeded, touch: :completed_at)
        alert.transition_to!(:succeeded, touch: :completed_at)
        complete_broadcast!
      when "busy", "no-answer", "failed", "canceled"
        delivery_attempt.transition_to!(:failed, touch: :completed_at)
        if alert.max_delivery_attempts_reached?
          alert.transition_to!(:failed, touch: :completed_at)
          complete_broadcast!
        else
          RetryAlertJob.set(wait: 15.minutes).perform_later(alert)
        end
      end
    end
  end

  private

  def alert
    delivery_attempt.alert
  end

  def broadcast
    delivery_attempt.broadcast
  end

  def complete_broadcast!
    broadcast.transition_to!(:completed, touch: :completed_at) if broadcast.alerts.where(status: :pending).none?
  end
end
