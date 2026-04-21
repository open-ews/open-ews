class DropUnusedTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :pghero_query_stats
    drop_table :batch_operations
  end
end
