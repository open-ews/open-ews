class AddSubdomainToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :subdomain, :citext

    reversible do |dir|
      dir.up do
        Account.find_each do |account|
          account.update_columns(subdomain: account.name.parameterize)
        end
      end
    end

    change_column_null :accounts, :subdomain, false
    add_index :accounts, :subdomain, unique: true
  end
end
