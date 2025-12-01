class AddDeviseTwoFactorToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :consumed_timestep, :integer
    add_column :users, :otp_required_for_login, :boolean, null: false, default: true
  end
end
