class CreateBroadcastBeneficiaryGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :broadcast_beneficiary_groups do |t|
      t.references(:broadcast, null: false, foreign_key: { on_delete: :cascade }, index: false)
      t.references(:beneficiary_group, null: false, foreign_key: { on_delete: :cascade }, index: false)
      t.timestamps
    end

    add_index(:broadcast_beneficiary_groups, [ :broadcast_id, :beneficiary_group_id ], unique: true)
  end
end
