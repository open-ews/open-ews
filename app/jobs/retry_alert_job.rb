class RetryAlertJob < ApplicationJob
  def perform(alert)
    return if alert.completed? || alert.max_delivery_attempts_reached?

    alert.delivery_attempts.create!(
      beneficiary: alert.beneficiary,
      broadcast: alert.broadcast,
      phone_number: alert.beneficiary.phone_number,
      status: :created
    )
  end
end
