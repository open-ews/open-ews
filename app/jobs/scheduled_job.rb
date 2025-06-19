class ScheduledJob < ApplicationJob
  queue_as AppSettings.fetch(:aws_sqs_high_priority_queue_name)

  def perform
    Account.find_each do |account|
      queue_delivery_attempts(account)
    end

    update_delivery_attempts
  end

  private

  def queue_delivery_attempts(account)
    delivery_attempts = DeliveryAttempt.where(status: :created).where(broadcast_id: account.broadcasts.where(status: :running).select(:id))

    delivery_attempts.joins(:notification).order("notifications.priority").limit(account.delivery_attempt_queue_limit).each do |delivery_attempt|
      delivery_attempt.transition_to!(:queued)
      InitiateDeliveryAttemptJob.perform_later(delivery_attempt)
    end
  end

  def update_delivery_attempts
    delivery_attempts_with_unknown_status.find_each do |delivery_attempt|
      UpdateDeliveryAttemptStatusJob.perform_later(delivery_attempt)
    end

    delivery_attempts_with_unknown_status.update_all(status_update_queued_at: Time.current)
  end

  def delivery_attempts_with_unknown_status
    DeliveryAttempt.where(status: :initiated, initiated_at: ..10.minutes.ago).merge(
      DeliveryAttempt.where(status_update_queued_at: nil).or(DeliveryAttempt.where(status_update_queued_at: ..15.minutes.ago))
    )
  end
end
