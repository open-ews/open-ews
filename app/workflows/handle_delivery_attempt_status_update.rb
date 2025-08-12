class HandleDeliveryAttemptStatusUpdate < ApplicationWorkflow
  attr_reader :delivery_attempt, :status_update, :logger

  def initialize(delivery_attempt, status_update:, **options)
    super()
    @delivery_attempt = delivery_attempt
    @status_update = status_update
    @logger = options.fetch(:logger, Rails.logger)
  end

  def call
    return if delivery_attempt.completed?

    ApplicationRecord.transaction do
      delivery_attempt.metadata["somleng_status"] = status_update.status

      case status_update.desired_status
      when "completed"
        delivery_attempt.transition_to!(:succeeded, touch: :completed_at)
        complete_notification(:succeeded)
        complete_broadcast
      when "failed"
        if notification.max_delivery_attempts_reached?
          complete_notification(:failed)
          complete_broadcast
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

  def complete_notification(status)
    notification.transition_to(status, touch: :completed_at)
  end

  def complete_broadcast
    broadcast.transition_to(:completed, touch: :completed_at) if broadcast.notifications.where(status: :pending).none?
  end
end
