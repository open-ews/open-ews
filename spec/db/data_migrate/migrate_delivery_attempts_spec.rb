require "rails_helper"
require Rails.root.join("db/data_migrate/migrate_delivery_attempts")

RSpec.describe MigrateDeliveryAttempts do
  it "migrates delivery attempts" do
    completed_delivery_attempt = create(
      :delivery_attempt, status: :completed, duration: 5, remote_status: "completed", remote_call_id: "call-sid"
    )
    errored_delivery_attempt = create(
      :delivery_attempt, status: :errored, remote_error_message: "Error message"
    )
    delivery_attempts_to_be_failed = [ :busy, :canceled, :failed, :not_answered, :expired ].map do |status|
      create(:delivery_attempt, status:, remote_status: status, remote_call_id: SecureRandom.uuid)
    end
    queued_delivery_attempt = create(:delivery_attempt, status: :queued)

    queued_alert = create(:alert, status: :queued)
    completed_alert = create(:alert, status: :completed)
    failed_alert = create(:alert, status: :failed)

    MigrateDeliveryAttempts.new.call

    expect(completed_delivery_attempt.reload).to have_attributes(
      metadata: {
        "somleng_call_sid" => "call-sid",
        "somleng_status" => "completed",
        "call_duration" => 5
      },
      status: "succeeded",
      completed_at: be_present,
      queued_at: be_present
    )
    expect(errored_delivery_attempt.reload).to have_attributes(
      metadata: {
        "somleng_error_message" => "Error message"
      },
      errored_at: be_present,
      queued_at: be_present
    )
    delivery_attempts_to_be_failed.each do |delivery_attempt|
      expect(delivery_attempt.reload).to have_attributes(
        status: "failed",
        queued_at: be_present,
        completed_at: be_present,
        metadata: {
          "somleng_status" => delivery_attempt.remote_status,
          "somleng_call_sid" => be_present,
          "call_duration" => be_present
        }
      )
    end
    expect(queued_delivery_attempt.reload).to have_attributes(
      status: "queued",
      queued_at: be_present
    )
    expect(queued_alert.reload).to have_attributes(
      status: "pending"
    )
    expect(completed_alert.reload).to have_attributes(
      status: "succeeded",
      completed_at: be_present
    )
    expect(failed_alert.reload).to have_attributes(
      status: "failed",
      completed_at: be_present
    )
  end
end
