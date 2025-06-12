class AddIndexOnNotificationsPhoneNumber < ActiveRecord::Migration[8.0]
  def change
    add_index(:notifications, [ :broadcast_id, :phone_number ], unique: true)
  end
end
