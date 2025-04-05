class AddTimestampsToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column(:alerts, :completed_at, :datetime)
  end
end
