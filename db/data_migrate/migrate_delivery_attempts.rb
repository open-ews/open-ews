module DataMigrate
  class MigrateDeliveryAttempts
    def call
      puts "#{Time.current} Deleting delivery attempts without an alert"
      DeliveryAttempt.where(alert_id: nil).delete_all

      puts "#{Time.current} Updating delivery attempts for where there is a remote call id"

      ActiveRecord::Base.connection.execute <<~SQL
        UPDATE delivery_attempts
        SET metadata = jsonb_set(
          jsonb_set(
            jsonb_set(
              metadata,
              '{somleng_call_sid}',
              to_jsonb(remote_call_id::text)
            ),
            '{somleng_status}',
            to_jsonb(remote_status::text)
          ),
          '{call_duration}',
          to_jsonb(duration::int)
        )
        WHERE remote_call_id IS NOT NULL;
      SQL

      puts "#{Time.current} Updating delivery attempts for where there is an error message"

      ActiveRecord::Base.connection.execute <<~SQL
        UPDATE delivery_attempts
        SET metadata = jsonb_set(
          metadata,
          '{somleng_error_message}',
          to_jsonb(remote_error_message::text)
        )
        WHERE remote_error_message IS NOT NULL;
      SQL

      puts "#{Time.current} Setting initiated_at for delivery attempts with a remote call id"
      DeliveryAttempt.where(initiated_at: nil).where.not(remote_call_id: nil).update_all("initiated_at = created_at")
      puts "#{Time.current} Clearing initiated_at for delivery attempts with a remote call id"
      DeliveryAttempt.where.not(initiated_at: nil).where(remote_call_id: nil).update_all(initiated_at: nil)
      puts "#{Time.current} Updating failed delivery attempts"
      DeliveryAttempt.where(status: [ :errored, :busy, :canceled, :failed, :not_answered, :expired ]).update_all("queued_at = created_at, completed_at = updated_at, status = 'failed'")
      puts "#{Time.current} Updating completed delivery attempts"
      DeliveryAttempt.where(status: :completed).update_all("queued_at = created_at, completed_at = updated_at, status = 'succeeded'")
      puts "#{Time.current} Updating queued delivery attempts"
      DeliveryAttempt.where(status: :queued).where(queued_at: nil).update_all("queued_at = updated_at")

      puts "#{Time.current} Updating queued alerts"
      Alert.where(status: :queued).update_all(status: :pending)
      puts "#{Time.current} Updating completed alerts"
      Alert.where(status: :completed).update_all(status: :succeeded)

      puts "#{Time.current} Setting completed_at for completed alerts"
      ActiveRecord::Base.connection.execute <<~SQL
        UPDATE alerts
        SET completed_at = latest_delivery_attempts.completed_at, updated_at = latest_delivery_attempts.completed_at
        FROM (
          SELECT DISTINCT ON (alert_id) alert_id, completed_at
          FROM delivery_attempts
          WHERE status IN ('succeeded', 'failed')
          ORDER BY alert_id, completed_at DESC
        ) AS latest_delivery_attempts
        WHERE alerts.id = latest_delivery_attempts.alert_id AND "alerts"."status" IN ('succeeded', 'failed');
      SQL

      puts "#{Time.current} Setting started_at on running or stopped broadcasts"
      Broadcast.where(status: [ :running, :stopped ]).update_all("started_at = created_at")
      puts "#{Time.current} Deleting delivery attempts from pending broadcasts"
      DeliveryAttempt.joins(:alert).joins(:broadcast).where(broadcasts: { status: :pending }, alerts: { status: :pending }).delete_all
      puts "#{Time.current} Deleting alerts from pending broadcasts"
      Alert.where(status: :pending).joins(:broadcast).where(broadcasts: { status: :pending }).delete_all

      DeliveryAttempt.where(status: :queued, created_at: ..1.day.ago).update_all("status = 'failed', completed_at = updated_at")

      puts "#{Time.current} Update alerts to failed for errored delivery attempts"
      ActiveRecord::Base.connection.execute <<~SQL
        UPDATE alerts
        SET status = 'failed', completed_at = errored_delivery_attempts.completed_at, updated_at = errored_delivery_attempts.completed_at
        FROM (
          SELECT last_delivery_attempts.*
          FROM (SELECT DISTINCT ON (alert_id) * FROM \"delivery_attempts\" ORDER BY alert_id, id DESC) last_delivery_attempts
          WHERE (last_delivery_attempts.initiated_at IS NULL AND last_delivery_attempts.status = 'failed')
        ) AS errored_delivery_attempts
        WHERE alerts.id = errored_delivery_attempts.alert_id AND "alerts"."status" = 'pending';
      SQL

      puts "#{Time.current} Update alerts to failed for failed delivery attempts long ago"
      ActiveRecord::Base.connection.execute <<~SQL
        UPDATE alerts
        SET status = 'failed', completed_at = failed_delivery_attempts.completed_at, updated_at = failed_delivery_attempts.completed_at
        FROM (
          SELECT last_delivery_attempts.*
          FROM (SELECT DISTINCT ON (alert_id) * FROM \"delivery_attempts\" ORDER BY alert_id, id DESC) last_delivery_attempts
          WHERE ("last_delivery_attempts"."completed_at" <= '2025-04-08 08:29:45.595090' AND last_delivery_attempts.status IN ('failed'))
        ) AS failed_delivery_attempts
        WHERE alerts.id = failed_delivery_attempts.alert_id AND "alerts"."status" = 'pending';
      SQL

      puts "#{Time.current} Marking broadcasts with no alerts as pending"
      Broadcast.where(status: [ :running, :stopped ]).left_joins(:alerts).where(alerts: { id: nil }).update_all(status: :pending, started_at: nil)

      puts "#{Time.current} Marking broadcasts with no pending alerts as completed"
      Broadcast.where(status: [ :running, :stopped ]).joins("LEFT JOIN alerts ON alerts.broadcast_id = broadcasts.id AND alerts.status = 'pending'").where(alerts: { id: nil }).update_all(status: :completed)

      puts "#{Time.current} Setting completed at for completed broadcasts"
      ActiveRecord::Base.connection.execute <<~SQL
        UPDATE broadcasts
        SET completed_at = latest_alerts.completed_at
        FROM (
          SELECT DISTINCT ON (broadcast_id) broadcast_id, completed_at
          FROM alerts
          WHERE status IN ('succeeded', 'failed')
          ORDER BY broadcast_id, completed_at DESC
        ) AS latest_alerts
        WHERE broadcasts.id = latest_alerts.broadcast_id AND "broadcasts"."status" IN ('completed');
      SQL
    end
  end
end

DataMigrate::MigrateDeliveryAttempts.new.call if Rails.env.production?
