class AddIndexOnNotificationsOnStatusCreatedAtBroadcastId < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index(:notifications, [ :status, :created_at, :broadcast_id ], algorithm: :concurrently)
  end
end
