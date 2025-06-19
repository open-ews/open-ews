class AddIndexOnDeliveryAttemptsOnIdAndLockVersion < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :delivery_attempts,
              [ :id, :lock_version ],
              algorithm: :concurrently
  end
end
