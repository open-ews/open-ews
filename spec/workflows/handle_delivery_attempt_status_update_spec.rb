require "rails_helper"

RSpec.describe HandleDeliveryAttemptStatusUpdate do
  it "handles completed events" do
    broadcast = create(:broadcast, :running)
    alert = create(:alert, :pending, broadcast:)
    delivery_attempt = create(:delivery_attempt, :initiated, alert:)

    HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "completed")

    expect(delivery_attempt).to have_attributes(
      status: "succeeded",
      completed_at: be_present
    )
    expect(alert).to have_attributes(
      status: "succeeded",
      completed_at: be_present
    )
    expect(broadcast).to have_attributes(
      status: "completed",
      completed_at: be_present
    )
  end

  it "retries the alert after failed events" do
    travel_to(Time.current) do
      account = create(:account, max_delivery_attempts_for_alert: 3)
      broadcast = create(:broadcast, :running, account:)
      alert = create(:alert, :pending, broadcast:)
      delivery_attempt = create(:delivery_attempt, :initiated, alert:)

      HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "failed")

      expect(delivery_attempt).to have_attributes(
        status: "failed",
        completed_at: be_present
      )
      expect(alert).to have_attributes(
        status: "pending",
        completed_at: be_blank
      )
      expect(broadcast).to have_attributes(
        status: "running"
      )
      expect(RetryAlertJob).to have_been_enqueued.at(15.minutes.from_now).with(alert)
    end
  end

  it "marks the alert as failed after max retries" do
    account = create(:account, max_delivery_attempts_for_alert: 1)
    broadcast = create(:broadcast, :running, account:)
    alert = create(:alert, :pending, broadcast:)
    delivery_attempt = create(:delivery_attempt, :initiated, alert:)

    HandleDeliveryAttemptStatusUpdate.call(delivery_attempt, status: "failed")

    expect(delivery_attempt).to have_attributes(
      status: "failed",
      completed_at: be_present
    )
    expect(alert).to have_attributes(
      status: "failed",
      completed_at: be_present
    )
    expect(broadcast).to have_attributes(
      status: "completed",
      completed_at: be_present
    )

    expect(RetryAlertJob).not_to have_been_enqueued
  end
end
