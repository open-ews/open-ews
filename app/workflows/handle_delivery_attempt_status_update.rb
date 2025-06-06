class HandleDeliveryAttemptStatusUpdate < ApplicationWorkflow
  attr_reader :delivery_attempt, :status

  def initialize(delivery_attempt, status:)
    super()
    @delivery_attempt = delivery_attempt
    @status = status
  end

  def call
    return if delivery_attempt.completed?

    ApplicationRecord.transaction do
      case status
      when "completed"
        delivery_attempt.transition_to!(:succeeded, touch: :completed_at)
        notification.transition_to!(:succeeded, touch: :completed_at)
        complete_broadcast!
      when "busy", "no-answer", "failed", "canceled"
        delivery_attempt.transition_to!(:failed, touch: :completed_at)
        if notification.max_delivery_attempts_reached?
          notification.transition_to!(:failed, touch: :completed_at)
          complete_broadcast!
        else
          RetryNotificationJob.set(wait: 15.minutes).perform_later(notification)
        end
      end
    end
  end

  private

  def notification
    delivery_attempt.notification
  end

  def broadcast
    delivery_attempt.broadcast
  end

  def complete_broadcast!
    broadcast.transition_to!(:completed, touch: :completed_at) if broadcast.notifications.where(status: :pending).none?
  end
end
