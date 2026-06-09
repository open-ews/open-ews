class AddCreatedViaToBroadcasts < ActiveRecord::Migration[8.1]
  def change
    add_column :broadcasts, :created_via, :string

    reversible do |dir|
      dir.up do
        Broadcast.where(created_via: nil, created_by: nil).update_all(created_via: "api")
        Broadcast.where(created_via: nil).where.not(created_by: nil).update_all(created_via: "dashboard")
      end
    end

    change_column_null :broadcasts, :created_via, false
    add_index :broadcasts, :created_via
  end
end
