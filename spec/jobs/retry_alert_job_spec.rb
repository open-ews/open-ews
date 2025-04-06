require "rails_helper"

RSpec.describe RetryAlertJob do
  it "retries an alert" do
    alert = create(:alert, :pending)
    delivery_attempt = create(:delivery_attempt, :failed, alert:)

    RetryAlertJob.perform_now(alert)

    expect(alert.delivery_attempts).to contain_exactly(
      delivery_attempt,
      have_attributes(
        status: "created",
        broadcast: alert.broadcast,
        beneficiary: alert.beneficiary,
        phone_number: alert.beneficiary.phone_number
      )
    )
  end

  it "does not retry an alert that is completed" do
    alert = create(:alert, :succeeded)
    delivery_attempt = create(:delivery_attempt, :succeeded, alert:)

    RetryAlertJob.perform_now(alert)

    expect(alert.delivery_attempts).to contain_exactly(delivery_attempt)
  end

  it "does not retry an alert that has reached max retries" do
    account = create(:account, settings: { max_delivery_attempts_for_alert: 1 })
    alert = create(:alert, :pending, broadcast: create(:broadcast, account:))
    delivery_attempt = create(:delivery_attempt, :failed, alert:)

    RetryAlertJob.perform_now(alert)

    expect(alert.delivery_attempts).to contain_exactly(delivery_attempt)
  end
end
