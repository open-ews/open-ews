require "rails_helper"
require Rails.root.join("db/data_migrate/migrate_delivery_attempts")

module DataMigrate
  RSpec.describe MigrateDeliveryAttempts do
    it "migrates delivery attempts" do
      running_broadcast = create(:broadcast, status: :running)
      pending_broadcast = create(:broadcast, status: :pending)
      running_broadcast_with_no_alerts = create(:broadcast, status: :running)
      stopped_broadcast_with_no_alerts = create(:broadcast, status: :stopped)
      running_broadcast_with_only_completed_alerts = create(:broadcast, status: :running)
      stopped_broadcast_with_only_completed_alerts = create(:broadcast, status: :stopped)
      failed_delivery_attempt_from_running_broadcast = create(
        :delivery_attempt, alert: create(:alert, broadcast: running_broadcast_with_only_completed_alerts, status: :failed),
        status: "not_answered"
      )
      completed_delivery_attempt_from_running_broadcast = create(
        :delivery_attempt, alert: create(:alert, broadcast: running_broadcast_with_only_completed_alerts, status: :completed),
        status: "completed"
      )
      failed_delivery_attempt_from_stopped_broadcast = create(
        :delivery_attempt, alert: create(:alert, broadcast: stopped_broadcast_with_only_completed_alerts, status: :failed),
        status: "not_answered"
      )

      completed_delivery_attempt = create(
        :delivery_attempt, alert: create(:alert, broadcast: running_broadcast),
        status: :completed, duration: 5, remote_status: "completed", remote_call_id: "call-sid"
      )
      errored_delivery_attempt = create(
        :delivery_attempt, alert: create(:alert, status: :queued, broadcast: running_broadcast),
        status: :errored, remote_error_message: "Error message", initiated_at: Time.current
      )
      delivery_attempts_to_be_failed = [ :busy, :canceled, :failed, :not_answered, :expired ].map do |status|
        create(
          :delivery_attempt, alert: create(:alert, broadcast: running_broadcast),
          status:, remote_status: status, remote_call_id: SecureRandom.uuid)
      end

      queued_delivery_attempt = create(
        :delivery_attempt,
        alert: create(:alert, broadcast: running_broadcast),
        status: :queued
      )

      queued_alert = create(:alert, broadcast: running_broadcast, status: :queued)
      completed_alert = create(:alert, broadcast: running_broadcast, status: :completed)
      create(:delivery_attempt, alert: completed_alert, status: :busy)
      create(:delivery_attempt, alert: completed_alert, status: :failed)
      last_delivery_attempt_for_completed_alert = create(:delivery_attempt, alert: completed_alert, status: :completed)
      failed_alert = create(:alert, broadcast: running_broadcast, status: :failed)
      create(:delivery_attempt, alert: failed_alert, status: :failed)
      last_delivery_attempt_for_failed_alert = create(:delivery_attempt, alert: failed_alert, status: :not_answered)

      alert_from_pending_broadcast = create(:alert, broadcast: pending_broadcast, status: :queued)
      delivery_attempt_from_pending_broadcast = create(:delivery_attempt, alert: alert_from_pending_broadcast, status: :created)

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
        queued_at: be_present,
        status: "failed",
        completed_at: be_present,
        initiated_at: nil,
        alert: have_attributes(
          status: "failed",
          completed_at: errored_delivery_attempt.reload.completed_at
        )
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
        completed_at: last_delivery_attempt_for_completed_alert.reload.updated_at,
        updated_at: last_delivery_attempt_for_completed_alert.reload.updated_at
      )
      expect(last_delivery_attempt_for_completed_alert.reload).to have_attributes(
        status: "succeeded"
      )
      expect(failed_alert.reload).to have_attributes(
        status: "failed",
        completed_at: last_delivery_attempt_for_failed_alert.reload.updated_at,
        updated_at: last_delivery_attempt_for_failed_alert.reload.updated_at
      )
      expect(last_delivery_attempt_for_failed_alert.reload).to have_attributes(
        status: "failed"
      )
      expect(running_broadcast.reload).to have_attributes(
        status: "running",
        started_at: running_broadcast.created_at
      )
      expect(DeliveryAttempt.find_by(id: delivery_attempt_from_pending_broadcast.id)).to be_nil

      expect(Alert.find_by(id: alert_from_pending_broadcast.id)).to be_nil
      expect(running_broadcast_with_no_alerts.reload).to have_attributes(
        status: "pending",
        started_at: nil
      )
      expect(stopped_broadcast_with_no_alerts.reload).to have_attributes(
        status: "pending",
        started_at: nil
      )
      expect(running_broadcast_with_only_completed_alerts.reload).to have_attributes(
        status: "completed",
        started_at: be_present,
        completed_at: completed_delivery_attempt_from_running_broadcast.reload.completed_at
      )
      expect(stopped_broadcast_with_only_completed_alerts.reload).to have_attributes(
        status: "completed",
        started_at: be_present,
        completed_at: failed_delivery_attempt_from_stopped_broadcast.reload.completed_at
      )
    end
  end
end
