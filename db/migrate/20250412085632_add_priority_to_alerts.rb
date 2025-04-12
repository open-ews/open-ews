class AddPriorityToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column(:alerts, :priority, :integer, default: 0, null: false)
    add_index(:alerts, :priority)
  end
end
