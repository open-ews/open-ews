class RemoveUnusedColumnsFromDeliveryAttempts < ActiveRecord::Migration[8.0]
  def change
    change_column_null(:delivery_attempts, :alert_id, false)
    change_column_null(:delivery_attempts, :beneficiary_id, false)
    change_column_null(:delivery_attempts, :broadcast_id, false)
    remove_column(:delivery_attempts, :remote_call_id, :string)
    remove_column(:delivery_attempts, :remote_status, :string)
    remove_column(:delivery_attempts, :remote_error_message, :string)
    remove_column(:delivery_attempts, :duration, :integer, null: false, default: 0)
  end
end
