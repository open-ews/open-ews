class AddAccountIdToBatchOperations < ActiveRecord::Migration[5.1]
  def up
    change_table(:batch_operations) do |t|
      t.references(:account, index: true, foreign_key: true, null: false)
    end
  end

  def down
    remove_reference(:batch_operations, :account)
  end
end
