class AddTimestampsToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column(:alerts, :completed_at, :datetime)
    add_index(:alerts, :completed_at)

    reversible do |dir|
      dir.up do
        Alert.where(status: :queued).update_all(status: :pending)
        Alert.where(status: :completed).update_all(status: :succeeded)
        Alert.where(status: [ :succeeded, :failed ]).update_all("completed_at = updated_at")
      end
    end
  end
end
