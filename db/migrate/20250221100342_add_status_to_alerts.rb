class AddStatusToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column :alerts, :status, :string, null: false
    add_index :alerts, :status
    remove_column :alerts, :answered, :boolean, default: false
  end
end
