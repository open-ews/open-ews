class AddContactsCountToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :contacts_count, :integer, null: false, default: 0
  end
end
