class AddISOCountryCodeToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column(:accounts, :iso_country_code, :citext)

    reversible do |dir|
      dir.up do
        account_countries = {
          1 => "KH",
          2 => "SO",
          3 => "KH",
          5 => "YE",
          6 => "IN",
          7 => "SL",
          8 => "KH",
          11 => "US",
          176 => "KH",
          9 => "CA",
          10 => "IN",
          44 => "IN",
          45 => "MX",
          77 => "EG",
          143 => "KH",
          110 => "ZM",
          209 => "LA",
          4 => "KH"
        }

        Account.find_each do |account|
          account.update_columns(iso_country_code: account_countries.fetch(account.id))
        end
      end
    end

    change_column_null(:accounts, :iso_country_code, false)
  end
end
