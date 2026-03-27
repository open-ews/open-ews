class AddNameToBroadcasts < ActiveRecord::Migration[8.1]
  def change
    add_column(:broadcasts, :name, :citext)
    add_index(:broadcasts, [ :account_id, :name ])
  end
end
