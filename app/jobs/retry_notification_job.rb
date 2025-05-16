class RetryNotificationJob < ApplicationJob
  def perform(notification)
    return if notification.completed? || notification.max_delivery_attempts_reached?

    notification.delivery_attempts.create!(
      beneficiary: notification.beneficiary,
      broadcast: notification.broadcast,
      phone_number: notification.beneficiary.phone_number,
      status: :created
    )
  end
end
