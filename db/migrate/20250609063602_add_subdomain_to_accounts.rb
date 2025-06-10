class AddSubdomainToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :subdomain, :citext, null: false
    add_index :accounts, :subdomain, unique: true
  end
end
