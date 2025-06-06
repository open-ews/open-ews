class AddIndexOnBroadcastIdAndIdNotifications < ActiveRecord::Migration[8.0]
  def change
    add_index(:notifications, [ :broadcast_id, :id ], order: { id: :desc })
  end
end
