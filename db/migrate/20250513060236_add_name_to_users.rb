class AddNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false
    remove_column :users, :metadata, :jsonb, default: {}, null: false
  end
end
