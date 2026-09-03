class CreateBroadcastTargetAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :broadcast_target_areas do |t|
      t.references :broadcast, null: false, foreign_key: { on_delete: :cascade }
      t.integer :administrative_level, null: false
      t.string :geocode, null: false
      t.index [ :broadcast_id, :administrative_level, :geocode ]
      t.index [ :administrative_level, :geocode ]

      t.timestamps
    end
  end
end
