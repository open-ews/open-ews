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
    Alert.where(status: [ :succeeded, :failed ]).update_all("completed_at = updated_at")
  end
end

MigrateDeliveryAttempts.new.call if Rails.env.production?
