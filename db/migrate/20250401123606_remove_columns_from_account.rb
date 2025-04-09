class RemoveColumnsFromAccount < ActiveRecord::Migration[8.0]
  def change
    remove_column(:accounts, :twilio_account_sid, :citext)
    remove_column(:accounts, :twilio_auth_token, :string)
    remove_column(:accounts, :somleng_api_host, :string)
    remove_column(:accounts, :somleng_api_base_url, :string)
    remove_column(:accounts, :platform_provider_name, :string)
    remove_column(:accounts, :permissions, :integer, default: 0)
    add_column(:accounts, :name, :string, null: false)
    add_column(:accounts, :delivery_attempt_queue_limit, :integer, null: false)
    add_column(:accounts, :alert_phone_number, :string)
    add_column(:accounts, :max_delivery_attempts_for_alert, :integer, null: false)
    remove_column(:accounts, :metadata, :jsonb, default: {}, null: false)
    remove_column(:accounts, :settings, :jsonb, default: {}, null: false)
  end
end
