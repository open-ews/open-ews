class AddAccountIdToCallouts < ActiveRecord::Migration[5.1]
  def up
    change_table(:callouts) do |t|
      t.references(:account, index: true, foreign_key: true, null: false)
    end
  end

  def down
    remove_reference(:callouts, :account)
  end
end
