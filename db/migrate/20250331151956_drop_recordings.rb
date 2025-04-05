class DropRecordings < ActiveRecord::Migration[8.0]
  def change
    drop_table(:recordings)
  end
end
