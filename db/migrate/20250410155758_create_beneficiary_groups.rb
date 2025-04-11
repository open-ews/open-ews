class CreateBeneficiaryGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiary_groups do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.timestamps
    end
  end
end
