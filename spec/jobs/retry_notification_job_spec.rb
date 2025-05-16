require "rails_helper"

RSpec.describe RetryNotificationJob do
  it "retries an notification" do
    notification = create(:notification, :pending)
    delivery_attempt = create(:delivery_attempt, :failed, notification:)

    RetryNotificationJob.perform_now(notification)

    expect(notification.delivery_attempts).to contain_exactly(
      delivery_attempt,
      have_attributes(
        status: "created",
        broadcast: notification.broadcast,
        beneficiary: notification.beneficiary,
        phone_number: notification.beneficiary.phone_number
      )
    )
  end

  it "does not retry an notification that is completed" do
    notification = create(:notification, :succeeded)
    delivery_attempt = create(:delivery_attempt, :succeeded, notification:)

    RetryNotificationJob.perform_now(notification)

    expect(notification.delivery_attempts).to contain_exactly(delivery_attempt)
  end

  it "does not retry an notification that has reached max retries" do
    account = create(:account, max_delivery_attempts_for_notification: 1)
    notification = create(:notification, :pending, broadcast: create(:broadcast, account:))
    delivery_attempt = create(:delivery_attempt, :failed, notification:)

    RetryNotificationJob.perform_now(notification)

    expect(notification.delivery_attempts).to contain_exactly(delivery_attempt)
  end
end
