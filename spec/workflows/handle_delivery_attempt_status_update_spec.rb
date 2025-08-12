require "rails_helper"

RSpec.describe HandleDeliveryAttemptStatusUpdate do
  it "handles completed events" do
    broadcast = create(:broadcast, :running)
    notification = create(:notification, :pending, broadcast:)
    delivery_attempt = create(:delivery_attempt, :initiated, notification:)

    HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "completed")

    expect(delivery_attempt).to have_attributes(
      status: "succeeded",
      completed_at: be_present
    )
    expect(notification).to have_attributes(
      status: "succeeded",
      completed_at: be_present
    )
    expect(broadcast).to have_attributes(
      status: "completed",
      completed_at: be_present
    )
  end

  it "retries the notification after failed events" do
    travel_to(Time.current) do
      account = create(:account, max_delivery_attempts_for_notification: 3)
      broadcast = create(:broadcast, :running, account:)
      notification = create(:notification, :pending, broadcast:)
      delivery_attempt = create(:delivery_attempt, :initiated, notification:)

      HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "failed")

      expect(delivery_attempt).to have_attributes(
        status: "failed",
        completed_at: be_present
      )
      expect(notification).to have_attributes(
        status: "pending",
        completed_at: be_blank
      )
      expect(broadcast).to have_attributes(
        status: "running"
      )
      expect(RetryNotificationJob).to have_been_enqueued.at(15.minutes.from_now).with(notification)
    end
  end

  it "marks the notification as failed after max retries" do
    account = create(:account, max_delivery_attempts_for_notification: 1)
    broadcast = create(:broadcast, :running, account:)
    notification = create(:notification, :pending, broadcast:)
    delivery_attempt = create(:delivery_attempt, :initiated, notification:)

    HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "failed")

    expect(delivery_attempt).to have_attributes(
      status: "failed",
      completed_at: be_present
    )
    expect(notification).to have_attributes(
      status: "failed",
      completed_at: be_present
    )
    expect(broadcast).to have_attributes(
      status: "completed",
      completed_at: be_present
    )

    expect(RetryNotificationJob).not_to have_been_enqueued
  end

  it "handles duplicates" do
    broadcast = create(:broadcast, :running)
    notification = create(:notification, :pending, broadcast:)
    delivery_attempt = create(:delivery_attempt, :failed, notification:)

    HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "failed")

    expect(delivery_attempt).to have_attributes(status: "failed")
  end

  it "handles notifications that have already succeeded" do
    broadcast = create(:broadcast, :completed)
    notification = create(:notification, :succeeded, broadcast:)
    delivery_attempt = create(:delivery_attempt, :initiated, notification:)

    HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "completed")

    expect(delivery_attempt).to have_attributes(status: "succeeded")
    expect(notification).to have_attributes(status: "succeeded")
    expect(broadcast).to have_attributes(status: "completed")
  end

  it "handles notifications that have already failed" do
    broadcast = create(:broadcast, :stopped)
    notification = create(:notification, :failed, broadcast:)
    delivery_attempt = create(:delivery_attempt, :initiated, notification:)

    HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "failed")

    expect(delivery_attempt).to have_attributes(status: "failed")
    expect(notification).to have_attributes(status: "failed")
    expect(broadcast).to have_attributes(status: "stopped")
    expect(RetryNotificationJob).to have_been_enqueued
  end
end
