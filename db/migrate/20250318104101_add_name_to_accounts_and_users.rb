class AddNameToAccountsAndUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :name, :string
    add_column :users, :name, :string
  end
end
