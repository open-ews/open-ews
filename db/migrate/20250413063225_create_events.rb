class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :type, null: false, index: true
      t.timestamps
    end
  end
end
