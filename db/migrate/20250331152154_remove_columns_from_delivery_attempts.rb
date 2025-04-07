class RemoveColumnsFromDeliveryAttempts < ActiveRecord::Migration[8.0]
  def change
    remove_column :delivery_attempts, :remote_direction, :string
    remove_column :delivery_attempts, :remote_response, :jsonb, default: {}, null: false
    remove_column :delivery_attempts, :remote_queue_response, :jsonb, default: {}, null: false
    remove_reference :delivery_attempts, :account, foreign_key: true
    rename_column :delivery_attempts, :remotely_queued_at, :initiated_at
    rename_column :delivery_attempts, :remote_status_fetch_queued_at, :status_update_queued_at
    add_column(:delivery_attempts, :queued_at, :datetime)
    add_column(:delivery_attempts, :completed_at, :datetime)
    add_column(:delivery_attempts, :errored_at, :datetime)
  end
end
