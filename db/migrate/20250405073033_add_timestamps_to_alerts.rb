class AddTimestampsToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column(:alerts, :completed_at, :datetime)
    add_index(:alerts, :completed_at)
  end
end
