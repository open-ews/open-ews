class CreateImports < ActiveRecord::Migration[8.0]
  def change
    create_table :imports do |t|
      t.string :resource_type, null: false
      t.string :status, null: false
      t.string :error_message
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
