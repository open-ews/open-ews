class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, null: true

    reversible do |dir|
      dir.up do
        User.where(role: nil).update_all(role: "member")
      end
    end

    change_column_null :users, :role, false
  end
end
