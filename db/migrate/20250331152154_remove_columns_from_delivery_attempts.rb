class RemoveColumnsFromDeliveryAttempts < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        DeliveryAttempt.where(remote_direction: :inbound).delete_all
        DeliveryAttempt.update_all("metadata = jsonb_set(metadata, '{somleng_call_sid}', to_json(remote_call_id)::jsonb)")
      end
    end

    remove_column :delivery_attempts, :remote_direction, :string
    remove_column :delivery_attempts, :remote_response, :jsonb, default: {}, null: false
    remove_column :delivery_attempts, :remote_queue_response, :jsonb, default: {}, null: false
    remove_column :delivery_attempts, :remote_status, :string
    remove_column :delivery_attempts, :remote_error_message, :text
    remove_reference :delivery_attempts, :account, foreign_key: true
    remove_column :delivery_attempts, :remote_call_id, :string
    rename_column :delivery_attempts, :remotely_queued_at, :initiated_at
    rename_column :delivery_attempts, :remote_status_fetch_queued_at, :status_update_queued_at
    change_column_null :delivery_attempts, :alert_id, false
    change_column_null :delivery_attempts, :broadcast_id, false
    add_column(:delivery_attempts, :queued_at, :datetime)
    add_column(:delivery_attempts, :completed_at, :datetime)
  end
end
