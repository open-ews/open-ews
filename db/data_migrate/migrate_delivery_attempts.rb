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

    puts "#{Time.current} Deleting broadcasts with no audio url"
    broadcasts_with_no_audio = Broadcast.where(audio_url: nil)
    BatchOperation::Base.where(broadcast_id: broadcasts_with_no_audio.select(:id)).delete_all
    broadcasts_with_no_audio.delete_all

    puts "#{Time.current} Attaching audio to and marking broadcasts as complete"
    Broadcast.find_each do |broadcast|
      attach_audio(broadcast) unless broadcast.audio_file.attached?

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
