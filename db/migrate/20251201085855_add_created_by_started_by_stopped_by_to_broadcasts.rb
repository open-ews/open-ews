class AddCreatedByStartedByStoppedByToBroadcasts < ActiveRecord::Migration[8.1]
  def change
    add_reference :broadcasts, :created_by, foreign_key: { to_table: :users, on_delete: :nullify }, null: true
    add_reference :broadcasts, :started_by, foreign_key: { to_table: :users, on_delete: :nullify }, null: true
    add_reference :broadcasts, :stopped_by, foreign_key: { to_table: :users, on_delete: :nullify }, null: true
    add_reference :broadcasts, :updated_by, foreign_key: { to_table: :users, on_delete: :nullify }, null: true
  end
end
