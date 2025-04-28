class CreateBeneficiaryGroupMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiary_group_memberships do |t|
      t.references :beneficiary, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :beneficiary_group, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.timestamps
    end

    add_index(:beneficiary_group_memberships, [ :beneficiary_id, :beneficiary_group_id ], unique: true)
  end
end
