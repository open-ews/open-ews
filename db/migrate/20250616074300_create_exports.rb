class CreateExports < ActiveRecord::Migration[8.0]
  def change
    create_table :exports do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :resource_type, null: false
      t.jsonb :scoped_to, null: false
      t.integer :progress_percentage, default: 0, null: false
      t.jsonb :filter_params, default: {}, null: false
      t.datetime :completed_at

      t.timestamps
    end
  end
end
