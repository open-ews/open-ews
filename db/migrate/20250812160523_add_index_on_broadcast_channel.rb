class AddIndexOnBroadcastChannel < ActiveRecord::Migration[8.0]
  def change
    add_index :broadcasts, :channel
  end
end
