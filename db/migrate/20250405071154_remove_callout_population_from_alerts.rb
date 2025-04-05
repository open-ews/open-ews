class RemoveCalloutPopulationFromAlerts < ActiveRecord::Migration[8.0]
  def change
    remove_reference :alerts, :callout_population, foreign_key: { to_table: :batch_operations }
  end
end
