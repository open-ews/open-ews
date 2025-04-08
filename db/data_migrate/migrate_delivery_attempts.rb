class MigrateDeliveryAttempts
  def call
    DeliveryAttempt.where(alert_id: nil).delete_all

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

    ActiveRecord::Base.connection.execute <<~SQL
      UPDATE delivery_attempts
      SET metadata = jsonb_set(
        metadata,
        '{somleng_error_message}',
        to_jsonb(remote_error_message::text)
      )
      WHERE remote_error_message IS NOT NULL;
    SQL

    DeliveryAttempt.where(status: [ :busy, :canceled, :failed, :not_answered, :expired ]).update_all("queued_at = created_at, completed_at = updated_at, status = 'failed'")
    DeliveryAttempt.where(status: :completed).update_all("queued_at = created_at, completed_at = updated_at, status = 'succeeded'")
    DeliveryAttempt.where(status: :queued).where(queued_at: nil).update_all("queued_at = updated_at")
    DeliveryAttempt.where(status: :errored).where(errored_at: nil).update_all("queued_at = updated_at, errored_at = updated_at")

    Alert.where(status: :queued).update_all(status: :pending)
    Alert.where(status: :completed).update_all(status: :succeeded)

    ActiveRecord::Base.connection.execute <<~SQL
      UPDATE alerts
      SET completed_at = latest_delivery_attempts.completed_at, updated_at = latest_delivery_attempts.completed_at
      FROM (
        SELECT DISTINCT ON (alert_id) alert_id, completed_at
        FROM delivery_attempts
        ORDER BY alert_id, completed_at DESC
      ) AS latest_delivery_attempts
      WHERE alerts.id = latest_delivery_attempts.alert_id AND "alerts"."status" IN ('succeeded', 'failed');
    SQL

    Broadcast.where(status: [ :running, :stopped ]).update_all("started_at = created_at")
    DeliveryAttempt.joins(:alert).joins(:broadcast).where(broadcasts: { status: :pending }, alerts: { status: :pending }).delete_all
    Alert.where(status: :pending).joins(:broadcast).where(broadcasts: { status: :pending }).delete_all

    Broadcast.find_each do |broadcast|
      if broadcast.audio_url.present? && !broadcast.audio_file.attached?
        attach_audio(broadcast)
      end

      if [ "running", "stopped" ].include?(broadcast.status)
        if broadcast.alerts.none?
          broadcast.update_columns(
            status: :pending,
            started_at: nil
          )
        elsif broadcast.alerts.where(status: :pending).none?
          broadcast.update_columns(
            status: :completed,
            completed_at: broadcast.alerts.last.updated_at
          )
        end
      end
    end
  end

  private

  def attach_audio(broadcast)
    DownloadBroadcastAudioFile.call(broadcast)
  rescue DownloadBroadcastAudioFile::Error
  end
end

MigrateDeliveryAttempts.new.call if Rails.env.production?
