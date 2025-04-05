class RemoveColumnsFromAccount < ActiveRecord::Migration[8.0]
  def change
    remove_column(:accounts, :twilio_account_sid, :citext)
    remove_column(:accounts, :twilio_auth_token, :string)
    remove_column(:accounts, :somleng_api_host, :string)
    remove_column(:accounts, :somleng_api_base_url, :string)
    remove_column(:accounts, :platform_provider_name, :string)
    remove_column(:accounts, :permissions, :integer, default: 0)
  end
end
