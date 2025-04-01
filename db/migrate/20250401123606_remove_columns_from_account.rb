class RemoveColumnsFromAccount < ActiveRecord::Migration[8.0]
  def change
    remove_column(:accounts, :twilio_account_sid)
    remove_column(:accounts, :twilio_auth_token)
    remove_column(:accounts, :somleng_api_host)
    remove_column(:accounts, :somleng_api_base_url)
    remove_column(:accounts, :platform_provider_name)
    remove_column(:accounts, :permissions)
  end
end
