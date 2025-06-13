class HandleDeliveryAttemptStatusUpdate < ApplicationWorkflow
  attr_reader :delivery_attempt, :status, :logger

  def initialize(delivery_attempt, status:, **options)
    super()
    @delivery_attempt = delivery_attempt
    @status = status
    @logger = options.fetch(:logger, Rails.logger)
  end

  def call
    return if delivery_attempt.completed?

    ApplicationRecord.transaction do
      case status
      when "completed"
        delivery_attempt.transition_to!(:succeeded, touch: :completed_at)
        complete_notification!(:succeeded)
        complete_broadcast!
      when "busy", "no-answer", "failed", "canceled"
        if notification.max_delivery_attempts_reached?
          complete_notification!(:failed)
          complete_broadcast!
        else
          RetryNotificationJob.set(wait: 15.minutes).perform_later(notification)
        end

        delivery_attempt.transition_to!(:failed, touch: :completed_at)
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

  def complete_notification!(status)
    notification.transition_to!(status, touch: :completed_at)
  rescue StateMachine::Machine::InvalidStateTransitionError => e
    logger.warn(e.message)
  end

  def complete_broadcast!
    broadcast.transition_to!(:completed, touch: :completed_at) if broadcast.notifications.where(status: :pending).none?
  rescue StateMachine::Machine::InvalidStateTransitionError => e
    logger.warn(e.message)
  end
end
