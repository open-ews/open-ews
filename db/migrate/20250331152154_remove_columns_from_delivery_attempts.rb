class RemoveColumnsFromDeliveryAttempts < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        DeliveryAttempt.where(alert_id: nil).delete_all

        say_with_time "Migrating delivery attempts" do
          execute <<-SQL
          UPDATE delivery_attempts
          SET metadata = jsonb_set(
            metadata,
            '{somleng_call_sid}',
            to_jsonb(remote_call_id)
          )
          WHERE remote_call_id IS NOT NULL;
          SQL
        end
      end
    end

    remove_column :delivery_attempts, :remote_direction, :string
    remove_column :delivery_attempts, :remote_response, :jsonb, default: {}, null: false
    remove_column :delivery_attempts, :remote_queue_response, :jsonb, default: {}, null: false
    remove_column :delivery_attempts, :remote_status, :string
    remove_column :delivery_attempts, :remote_error_message, :text
    remove_column :delivery_attempts, :duration, :integer, default: 0, null: false
    remove_reference :delivery_attempts, :account, foreign_key: true
    remove_column :delivery_attempts, :remote_call_id, :string
    rename_column :delivery_attempts, :remotely_queued_at, :initiated_at
    rename_column :delivery_attempts, :remote_status_fetch_queued_at, :status_update_queued_at
    change_column_null :delivery_attempts, :alert_id, false
    change_column_null :delivery_attempts, :broadcast_id, false
    add_column(:delivery_attempts, :queued_at, :datetime)
    add_column(:delivery_attempts, :completed_at, :datetime)
    add_column(:delivery_attempts, :errored_at, :datetime)
  end
end
