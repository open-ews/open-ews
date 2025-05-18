class AddISOCountryCodeToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :iso_country_code, :string
  end
end
