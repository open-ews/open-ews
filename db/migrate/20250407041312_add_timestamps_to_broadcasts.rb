class AddTimestampsToBroadcasts < ActiveRecord::Migration[8.0]
  def change
    add_column(:broadcasts, :started_at, :datetime)
    add_column(:broadcasts, :completed_at, :datetime)
    remove_reference(:broadcasts, :created_by, foreign_key: {  to_table: :users })
    remove_column(:broadcasts, :settings, :jsonb, default: {}, null: false)
  end
end
