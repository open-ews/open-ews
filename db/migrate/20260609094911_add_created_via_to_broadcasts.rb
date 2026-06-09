class AddCreatedViaToBroadcasts < ActiveRecord::Migration[8.1]
  def change
    add_column :broadcasts, :created_via, :string, null: false
    add_index :broadcasts, :created_via
  end
end
