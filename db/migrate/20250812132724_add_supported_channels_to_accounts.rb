class AddSupportedChannelsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :supported_channels, :string, array: true, default: [], null: false

    reversible do |dir|
      dir.up do
        Account.update_all(supported_channels: [ :voice ])
      end
    end
  end
end
